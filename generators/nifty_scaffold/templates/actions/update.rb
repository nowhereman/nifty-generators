  def update
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
      flash[:notice] = I18n.t('flash.<%= plural_name %>.update.notice', :default => "Successfully updated <%= name.underscore.humanize.downcase %>.")
      respond_to do |format|
        format.html { redirect_to <%= item_path('url') %> }
        <%- if options[:jquery] -%>
        format.js
        <%- end -%>
      end
    else
      render :action => 'edit'
    end
  end
