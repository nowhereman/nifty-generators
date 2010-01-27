  it "update action should render edit template when model is invalid" do
    @<%= singular_name %>.stub!(:valid?).and_return(false)
    put :update, :id => <%= class_name %>.first
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    @<%= singular_name %>.stub!(:valid?).and_return(true)
    put :update, :id => <%= class_name %>.first
    response.should redirect_to(<%= item_path_for_spec('url') %>)
  end
