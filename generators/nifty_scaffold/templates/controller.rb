class <%= plural_class_name %>Controller < ApplicationController  
  <%- if options[:declarative_authorization] -%>
  # Uncomment to enable authorization rules
#  filter_resource_access
  
  <%- end -%>
  <%= controller_methods :actions %>
end
