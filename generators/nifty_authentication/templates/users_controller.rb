class <%= user_plural_class_name %>Controller < ApplicationController
  <%- if options[:declarative_authorization] -%>  
  filter_resource_access # Enable authorization rules

  <%- end -%>
  def new
    @<%= user_singular_name %> = <%= user_class_name %>.new
  end
  
  def create
    <%- if options[:declarative_authorization] -%>
    params[:<%= user_singular_name %>][:role_ids] = [ Role.find_by_name('user').id ] unless params[:<%= user_singular_name %>][:role_ids] # default role is 'user'
    <%- end -%>
    @<%= user_singular_name %> = <%= user_class_name %>.new(params[:<%= user_singular_name %>])
    <%- if options[:declarative_authorization] -%>
    begin
    <%- end -%>
      if @<%= user_singular_name %>.save
      <%- unless options[:authlogic] -%>
        session[:<%= user_singular_name %>_id] = @<%= user_singular_name %>.id
      <%- end -%>
        flash[:notice] = I18n.t('authlogic.actions.login.notice', :default => 'Thank you for signing up! You are now logged in.')
        redirect_to root_url
      else
        render :action => 'new'
      end
    <%- if options[:declarative_authorization] -%>
    rescue Authorization::AttributeAuthorizationError => e
      flash[:alert] = I18n.t('common.errors.access_denied', :default => 'Sorry, you are not allowed to assign roles.')
      redirect_to root_url
    end
    <%- end -%>
  end

  def edit
    @<%= user_singular_name %> = current_user
  end

  def update
    @<%= user_singular_name %> = current_user
    <%- if options[:declarative_authorization] -%>
    params[:<%= user_singular_name %>][:role_ids] = [ Role.find_by_name('user').id ] unless params[:<%= user_singular_name %>][:role_ids] # default role is 'user'
    <%- end -%>
    if <%= user_singular_name %>.update_attributes(params[:<%= user_singular_name %>])
      flash[:notice] = I18n.t('flash.actions.update.alert', :default => 'Successfully updated profile.')
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
end
