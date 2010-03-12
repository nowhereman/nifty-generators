  def create
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
    if @<%= singular_name %>.save
      flash[:notice] = I18n.t('flash.<%= plural_name %>.create.notice', :default => "Successfully created <%= name.underscore.humanize.downcase %>.")
      respond_to do |format|
        format.html { redirect_to <%= item_path('url') %> }
        <%- if options[:jquery] -%>
        format.js
        <%- end -%>
      end
    else
      render :action => 'new'
    end
  end
