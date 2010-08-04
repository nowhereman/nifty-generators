module SessionExampleHelpers
  def create_roles
    @role_admin = Role.make(:name => 'admin')
    @role = Role.make
    @roles = [ @role, @role_admin ]
    Role.stub!(:find_by_name).and_return(@role)
    Role.stub!(:find).with(kind_of(Numeric)).and_return(@role)
    Role.stub!(:find).with(kind_of(::Enumerable)).and_return(@roles)
    Role.stub!(:find).with(any_args).and_return(@roles)
    Role.stub!(:all).and_return(@roles)
  end

  def create_users
    @user = User.make
    @users = [@user]
    User.stub!(:first).and_return(@user)
    User.stub!(:find).with(kind_of(Numeric)).and_return(@user)
    User.stub!(:find).with(kind_of(::Enumerable)).and_return(@users)
    User.stub!(:all).and_return(@users)
    User.stub!(:count).with(any_args).and_return(@users.length)
    create_user_session(@user)
  end

  def create_user_session(user)
    UserSession.stub!(:find).and_return( UserSession.create(user) )
  end

  def activate_session
    activate_authlogic
    create_roles
    create_users
  end

end
