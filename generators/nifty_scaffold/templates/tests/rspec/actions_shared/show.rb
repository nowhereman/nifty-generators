  it "show action should render show template" do
    get :show, :id => <%= class_name %>.first.id
    response.should render_template(:show)
  end
