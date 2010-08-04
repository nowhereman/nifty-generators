  it "update action should render edit template when model is invalid" do
    @<%= singular_name %>_bad.should_not be_valid
    put :update, :id => @<%= singular_name %>.id, :<%= singular_name %> => @<%= singular_name %>_bad.attributes
    response.should render_template(:edit)
  <%- if options[:inherited_resources] -%>
    flash[:alert].should == I18n.t('flash.<%= plural_name %>.update.alert')
    flash[:notice].should be_nil
  <%- end -%>
  end
  
  it "update action should redirect when model is valid" do
    @<%= singular_name %>.should be_valid
    put :update, :id => @<%= singular_name %>.id, :<%= singular_name %> => @<%= singular_name %>_new.attributes
    response.should redirect_to(<%= item_path_for_spec('url') %>)
  <%- if options[:inherited_resources] -%>
    flash[:alert].should be_nil
    flash[:notice].should == I18n.t('flash.<%= plural_name %>.update.notice')
  <%- end -%>
  end
