  def delete
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
    respond_to do |format|
      format.html # delete.html.erb
    end
  end