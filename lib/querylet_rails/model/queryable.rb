require 'querylet'

module QueryletRails
  module Model
    module Queryable
      extend ActiveSupport::Concern

      def query relative_path, data={}
        self.class.query relative_path, data
      end

      def select_value relative_path, data={}
        self.class.select_value relative_path, data
      end

      def select_values relative_path, data={}
        self.class.select_values relative_path, data
      end

      def select_object relative_path, data={}
        self.class.select_object relative_path, data
      end

      def select_array relative_path, data={}
        self.class.select_array relative_path, data
      end

      def select_all relative_path, data={}
        self.class.select_all relative_path, data
      end

      def select_paginate query, attrs, count
        self.class.select_paginate query, attrs, count
      end

      # This will fetch the current tenant id
      def current_tenant_id
        self.class.current_tenant_id
      end

      def set_tenant_id
        self.class.set_tenant_id
      end

      def reset_tenant_id
        self.class.reset_tenant_id
      end

      # This will apply the current tenant_id on the creation of a new model
      def initialize_tenant_id
        if new_record?
          if has_attribute?(:tenant_id) && self.tenant_id.nil?
            self.tenant_id = current_tenant_id
          end
        end
      end

      included do
        after_initialize :initialize_tenant_id
      end

      class_methods do
        # override this function
        def query_root
          Rails.root
        end

        def _query_wrap_object template
          <<-HEREDOC.chomp
(SELECT COALESCE(row_to_json(object_row),'{}'::json) FROM (
#{template.to_s.chomp}
) object_row);
          HEREDOC
        end

        def _query_wrap_array template
          <<-HEREDOC.chomp
(SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
#{template.to_s.chomp}
) array_row);
          HEREDOC
        end

        def current_tenant_id
          self.connection.execute('SHOW my.tenant_id').getvalue(0, 0).to_i
        end

        def set_tenant_id new_tenant_id
          raise "tenant_id not an valid value" unless new_tenant_id.is_a?(Integer)
          self.connection.execute "SET SESSION my.tenant_id = #{new_tenant_id}"
        end

        def reset_tenant_id
          self.connection.execute "RESET my.tenant_id"
        end

        def _query relative_path, data={}
          file_path = self.query_root.join('app','queries',relative_path + '.sql')
          template  = File.read file_path
          _query_compile_template template, data
        end

        def _query_compile_template template, data={}
          querylet = Querylet::Querylet.new path: self.query_root.join('app','queries').to_s
          begin
          querylet.compile(template).call(data)
          rescue => e
            puts ""
            puts "===== Querylet Compile Error Occured ====="
            template_annotated = ''
            template.split("\n").each_with_index do |line,i|
              template_annotated << "#{(i+1).to_s.rjust(3, " ")} | #{line}\n"
            end
            puts template_annotated
            raise e
          end
        end

        def query relative_path, data={}
          _query relative_path, data
        end

        def select_value relative_path, data={}
          sql = _query relative_path, data
          self.connection.select_value sql
        end

        def select_values relative_path, data={}
          sql = _query relative_path, data
          self.connection.select_values sql
        end

        def select_array relative_path, data={}
          sql = _query relative_path, data
          sql = self._query_wrap_array sql
          self.connection.select_value sql
        end

        def select_object relative_path, data={}
          sql = _query relative_path, data
          sql = self._query_wrap_object sql
          self.connection.select_value sql
        end

        def select_all relative_path, data={}
          sql = _query relative_path, data
          self.connection.select_all sql
        end

        def select_paginate relative_path, data, count
          file_path = self.query_root.join('app','queries',relative_path + '.sql')
          template  = File.read file_path
          if count
            sql = self._query_wrap_object template
            sql = self._query_compile_template sql, data
            self.connection.select_value sql
          else
            sql = self._query_wrap_array template
            sql = self._query_compile_template sql, data
            self.connection.select_value sql
          end
        end
      end
    end # Queryable
  end # Model
end # QueryletRails
