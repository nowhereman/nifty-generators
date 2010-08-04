  it "create action should render new template when model is invalid" do
    @<%= singular_name %>_bad.should_not be_valid
    post :create,  :<%= singular_name %> => @<%= singular_name %>_bad.attributes
    response.should render_template(:new)
  <%- if options[:inherited_resources] -%>
    flash[:alert].should == I18n.t('flash.<%= plural_name %>.create.alert')
    flash[:notice].should be_nil
  <%- end -%>
  end
  
  it "create action should redirect when model is valid" do
    @<%= singular_name %>_new.should be_valid
    post :create, :<%= singular_name %> => @<%= singular_name %>_new.attributes
    response.should redirect_to(<%= item_path_for_spec('url') %>)
  <%- if options[:inherited_resources] -%>
    flash[:alert].should be_nil
    flash[:notice].should == I18n.t('flash.<%= plural_name %>.create.notice')
  <%- end -%>
  end
