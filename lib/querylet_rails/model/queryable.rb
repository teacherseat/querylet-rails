require 'querylet'

module QueryletRails
  module Model
    module Queryable
      extend ActiveSupport::Concern
      # override this function

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

      module ClassMethods
        def query_root
          Rails.root
        end

        def query relative_path, data={}
          file_path = self.query_root.join('app','queries',relative_path + '.sql')
          template  = File.read file_path
          query_compile_template template, data
        end

        def query_compile_template template, data={}
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

        def select_value relative_path, data={}
          sql = self.query relative_path, data
          self.connection.select_value sql
        end

        def select_values relative_path, data={}
          sql = self.query relative_path, data
          self.connection.select_values sql
        end

        def select_array relative_path, data={}
          template = self.query relative_path, data
          sql = query_wrap_array template
          self.connection.select_value sql
        end

        def select_object relative_path, data={}
          template = self.query relative_path, data
          sql = query_wrap_object template
          self.connection.select_value sql
        end

        def select_all relative_path, data={}
          sql = self.query relative_path, data
          self.connection.select_all sql
        end

        def query_wrap_object template
          <<-HEREDOC.chomp
    (SELECT COALESCE(row_to_json(object_row),'{}'::json) FROM (
    #{template.to_s.chomp}
    ) object_row)
          HEREDOC
        end

        def query_wrap_array template
          <<-HEREDOC.chomp
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
    #{template.to_s.chomp}
    ) array_row)
          HEREDOC
        end

        def select_paginate relative_path, data, count
          file_path = self.query_root.join('app','queries',relative_path + '.sql')
          template  = File.read file_path
          if count
            sql = self.query_wrap_object template
            sql = self.query_compile_template sql, data
            self.connection.select_value sql
          else
            sql = self.query_wrap_array template
            sql = self.query_compile_template sql, data
            self.connection.select_value sql
          end
        end
      end
    end # Queryable
  end # Model
end # QueryletRails
