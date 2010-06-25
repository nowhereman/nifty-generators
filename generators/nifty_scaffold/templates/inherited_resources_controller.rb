class <%= plural_class_name %>Controller < InheritedResources::Base
  actions :<%= controller_actions.join(', :') %>
  respond_to :html, :xml, :json<%= ", :js" if options[:jquery] %>
 
  <%- if options[:declarative_authorization] -%>
  # Uncomment to enable authorization rules
#  filter_resource_access
  
  <%- end -%>
 	<%- if options[:will_paginate] -%>  
  protected
  def collection
    @<%= plural_name %> ||= end_of_association_chain.paginate :page => params[:page], :per_page => (params[:per_page] || 20)
  end
  <%- end -%>
end
