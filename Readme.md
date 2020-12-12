# Querylet Rails

## What is Querylet?

[Querylet](https://github.com/teacherseat/querylet) is a query template
langauge for Postgres to ease working with complex queries eg.

Similar to handlebars but a much simpler langague and specfically
designed for postgre queries.

```
{{#if count}}
{{> include 'admin.shared.paginate_select'}}
{{/else}}
{{> include 'admin.users.select'}}
{{/if}}
FROM users
WHERE true
AND 'customer' != ANY(users.role)
{{#if search}}
  AND (
    (coalesce(users.first_name, '') || ' ' || coalesce(users.last_name, '') ILIKE {{wild search}})
    OR users.email ILIKE {{wild search}}
  )
{{/if}}
{{#unless count}}
{{#if sort}}
ORDER BY {{sort}}
{{/else}}
ORDER BY users.id ASC
{{/if}}
{{> include 'admin.shared.paginate_offset'}}
{{/unless}}
```

## What is Querylet Rails?

Querylet Rails helps configure querylet for use in a Rails application.

It contains two files:

- querylet_rails/controller/queryable.rb (QueryletRails::Controller::Queryable)
- querylet_rails/model/queryable.rb      (QueryletRails::Model::Queryable)


## QueryletRails::Controller::Queryable

This module is a Rails Controller Concerns to include your ApplicationController

It defines the following controller methods:

- set_pagination_headers
- render_paginated
- render_paginated_json
- index_params

## QueryletRails::Model::Queryable

This module is a Rails Model Concerns to include your ApplicationRecord

It defines the following model methods:

- select_value and self.select_value
- select_values and self.select_values
- select_object and self.select_object
- select_array and self.select_array
- select_all and self.select_all
- select_paginate and self.select_paginate
- self.query_root
- self.query
- self.query_compile_template
- self.query_wrap_object
- self.query_wrap_array
