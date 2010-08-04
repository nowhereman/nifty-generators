  it "destroy action should destroy model and redirect to index action" do
    delete :destroy, :id => @<%= singular_name %>.id
    response.should redirect_to(<%= items_path('url') %>)
    <%= class_name %>.exists?(@<%= singular_name %>.id).should be_false
    <%- if options[:inherited_resources] -%>
    flash[:alert].should be_nil
    flash[:notice].should == I18n.t('flash.<%= plural_name %>.destroy.notice')
  <%- end -%>
  end
