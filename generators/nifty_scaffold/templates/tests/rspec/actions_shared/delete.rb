  it "delete action should render delete template" do
    get :delete, :id => <%= class_name %>.first.id
    response.should render_template(:delete)
  end
