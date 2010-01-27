  it "create action should render new template when model is invalid" do
    @<%= singular_name %>.stub!(:valid?).and_return(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    @<%= name.downcase %>.stub!(:valid?).and_return(true)
    post :create
    response.should redirect_to(<%= item_path_for_spec('url') %>)
  end
