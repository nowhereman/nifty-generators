  def destroy
    @<%= singular_name %> = <%= class_name %>.find( params[:id] )
    redirect_to(@<%= singular_name %>) and return if params[:cancel]
    @<%= singular_name %>.destroy
    flash[:notice] = I18n.t('flash.<%= plural_name %>.destroy.notice', :default => "Successfully destroyed <%= name.underscore.humanize.downcase %>.")
    respond_to do |format|
      format.html { redirect_to <%= items_path('url') %> }
      <%- if options[:jquery] -%>
      format.js
      <%- end -%>
    end
  end
