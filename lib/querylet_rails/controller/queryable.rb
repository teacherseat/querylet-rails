module QueryletRails
  module Controller
    module Queryable
      extend ActiveSupport::Concern

      def set_pagination_headers count_json
        json = JSON.parse(count_json)
        json = json.first if json.is_a?(Array)
        page = json['page']
        total = json['total_entries']
        per_page = json['per_page'] || 20
        pages = (total.to_f / per_page).ceil
        end_entry = page * per_page
        end_entry = total if end_entry > total
        headers["X-Pagination"] = {
          page: page,
          total:         total,
          total_pages:   pages,
          first_page:    page == 1,
          last_page:     page >= pages,
          previous_page: page - 1,
          next_page:     page + 1,
          out_of_bounds: page < 1 || page > pages,
          first_entry:    (page - 1) * per_page + 1,
          end_entry:  end_entry
        }.to_json
      end

      # AB - We should phase out {{sort}} in favour
      # of {{order}} {{by}} for more finetune control
      def render_paginated target, method, attrs
        if attrs.key?(:sort)
          name,dir = attrs[:sort].split ','
          v = [name]
          v.push dir.upcase if dir
          v = v.join ' '
          attrs[:sort] = v
          attrs[:order] = name
          attrs[:by]    = (dir || 'ASC').upcase
        end

        # Use the same query but to count all the records
        attrs[:count] = true
        count_json = target.send method, attrs
        set_pagination_headers count_json
        attrs.delete(:count)

        target.send method, attrs
      end

      def render_paginated_json target, method, attrs
        json = render_paginated target, method, attrs
        render json: json
      end

      def index_params
        params.permit :page, :search, :sort
      end
    end # Queryable
  end # Controller
end # QueryletRails
