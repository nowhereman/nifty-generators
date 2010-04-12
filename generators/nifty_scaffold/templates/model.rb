class <%= class_name %> < ActiveRecord::Base
  attr_accessible <%= attributes.map { |a| ":#{a.name}" }.join(", ") %>
  <%- if options[:hobofields] -%>

  fields do
  <%- attributes.map do |a| -%>
    <%= "#{a.name} :#{a.type}" %>
  <%- end -%>
  <%- unless options[:skip_timestamps] -%>
    timestamps
  <%- end -%>
  end
  <%- end -%>
end
