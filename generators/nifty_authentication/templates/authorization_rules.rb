# More info at http://github.com/stffn/declarative_authorization/blob/master/README.rdoc
authorization do
  role :admin do
    has_permission_on :users, :to => [:index, :show, :new, :create, :edit, :update, :destroy]
    has_permission_on :assignments, :to => [:index, :show, :new, :create, :edit, :update, :destroy]
  end

  role :user do
    has_permission_on :users, :to => [:show, :edit, :update] do
      if_attribute :id => is { user.id }
    end

    has_permission_on :assignments, :to => :create do
      if_attribute :role_id => is_in {
        # The default role is 'user'
        # If there is no users with important roles the first user can have a role != of 'user', e.g. 'admin' or 'moderator'
        # Otherwise, only users with 'admin' role can set different role than 'user'
        # You can change this behavior. But be careful to security issues, write tests.
        if ( User.count(:joins => :roles, :conditions => {'roles.name' => [ 'admin', 'moderator']}) == 0 ) || ( user.respond_to?(:"has_role?") && user.has_role?(:admin) )
          Role.all.map{ |role| role.id }
        else
          [ Role.find_by_name('user').id ]
        end
      }
    end

  end

  role :guest do
    has_permission_on :users, :to => [:new, :create]
  end

end