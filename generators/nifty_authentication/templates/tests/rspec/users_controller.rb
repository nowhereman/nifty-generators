require File.dirname(__FILE__) + '/../spec_helper'

<%- if options[:machinist] && options[:declarative_authorization] -%>
  def plan_<%= user_singular_name %>_with_roles(args = {})
    if args.blank? || args.is_a?(::Hash)
      <%= user_singular_name %> = <%= user_class_name %>.plan(args)
      <%= user_singular_name %>[:role_ids] = [ @role.id ]
      return <%= user_singular_name %>
    else
      # args is a User instance
      return args.attributes.merge(:password => args.password,
        :password_confirmation => args.password_confirmation,
        :roles => args.roles )
    end
  end

<%- end -%>
describe <%= user_plural_class_name %>Controller do
<%- unless options[:machinist] -%>
  fixtures :all
<%- end -%>
  integrate_views

<%- if options[:machinist] && options[:declarative_authorization] -%>
  before(:each) do
    @role_admin = Role.make(:name => 'admin')
    @role = Role.make
    @roles = [ @role, @role_admin ]
    Role.stub!(:find_by_name).and_return(@role)
    Role.stub!(:find).with(kind_of(Numeric)).and_return(@role)
    Role.stub!(:find).with(kind_of(::Enumerable)).and_return(@roles)
    Role.stub!(:find).with(any_args).and_return(@roles)
    Role.stub!(:all).and_return(@roles)

    @<%= user_singular_name %> = <%= user_class_name %>.make_unsaved
    @bad_<%= user_singular_name %> = <%= user_class_name %>.make_unsaved(:username => nil, :password_confirmation => "bad_password")
    @<%= user_singular_name %>s = [@<%= user_singular_name %>]
    <%= user_class_name %>.stub!(:first).and_return(@<%= user_singular_name %>)
    <%= user_class_name %>.stub!(:find).with(kind_of(Numeric)).and_return(@user)
    <%= user_class_name %>.stub!(:find).with( kind_of(::Enumerable) ).and_return(@<%= user_singular_name %>s)
    <%= user_class_name %>.stub!(:all).and_return(@<%= user_singular_name %>s)
    <%= user_class_name %>.stub!(:count).with(kind_of(::Enumerable)).and_return(0)
  end

  it "create action should render new template when model is invalid" do
    @bad_<%= user_singular_name %>.should_not be_valid
    post :create, :<%= user_singular_name %> => plan_<%= user_singular_name %>_with_roles(@bad_<%= user_singular_name %>)
    response.should render_template(:new)
    response.flash[:alert].should be_nil
    response.flash[:notice].should be_nil
  end

  it "create action should redirect when model is valid" do
    @<%= user_singular_name %>.should be_valid
    post :create, :<%= user_singular_name %> => plan_<%= user_singular_name %>_with_roles(@<%= user_singular_name %>)
    response.should redirect_to(root_url)
    flash[:alert].should_not == I18n.t('common.errors.access_denied')
    flash[:notice].should == I18n.t('authlogic.actions.login.notice')
    <%- unless options[:authlogic] -%>
    session['<%= user_singular_name %>_id'].should == assigns['<%= user_singular_name %>'].id
    <%- end -%>
    <%= user_class_name %>.stub!(:count).with(kind_of(::Enumerable)).and_return(1)
  end

<%- else -%>
  it "create action should render new template when model is invalid" do
    <%= user_class_name %>.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    <%= user_class_name %>.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(root_url)
  <%- unless options[:authlogic] -%>
    session['<%= user_singular_name %>_id'].should == assigns['<%= user_singular_name %>'].id
  <%- end -%>
  end

<%- end -%>
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

end