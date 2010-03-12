class <%= plural_class_name %>Controller < InheritedResources::Base
  actions :<%= controller_actions.join(', :') %>
  respond_to :html, :xml, :json<%= ", :js" if options[:jquery] %>
  
  <%- if controller_actions.include?('destroy') -%>
  def delete
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    respond_to do |format|
      format.html # delete.html.erb
    end
  end

  def destroy
    @<%= singular_name %> = <%= class_name %>.find( params[:id] )
    redirect_to(@<%= singular_name %>) and return if params[:cancel]
    destroy!
  end
  
  <%- end -%>
	<%- if options[:will_paginate] -%>  
  protected
  def collection
    @<%= plural_name %> ||= end_of_association_chain.paginate :page => params[:page], :per_page => (params[:per_page] || 20)
  end
  <%- end -%>
end
