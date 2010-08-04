  it "edit action should render edit template" do
    get :edit, :id => <%= class_name %>.first.id
    response.should render_template(:edit)
  end
