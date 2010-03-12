class <%= plural_class_name %>Controller < InheritedResources::Base
  actions :<%= controller_actions.join(', :') %>
	<%- if options[:will_paginate] -%>
  respond_to :html, :xml, :json<%= ", :js" if options[:jquery] %>
  
	protected
  def collection
    @<%= plural_name %> ||= end_of_association_chain.paginate :page => params[:page], :per_page => (params[:per_page] || 20)
  end
  <%- end -%>
end
