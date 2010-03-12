class <%= session_plural_class_name %>Controller < ApplicationController
<%- if options[:authlogic] -%>
  def new
    @<%= session_singular_name %> = <%= session_class_name %>.new
  end
  
  def create
    @<%= session_singular_name %> = <%= session_class_name %>.new(params[:<%= session_singular_name %>])
    if @<%= session_singular_name %>.save
      flash[:notice] = I18n.t('authlogic.actions.login.notice', :default => 'Logged in successfully.')
      redirect_to_target_or_default(root_url)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @<%= session_singular_name %> = <%= session_class_name %>.find
    @<%= session_singular_name %>.destroy
    flash[:notice] = I18n.t('authlogic.actions.logout.notice', :default => 'You have been logged out.')
    redirect_to root_url
  end
<%- else -%>
  def new
  end
  
  def create
    <%= user_singular_name %> = <%= user_class_name %>.authenticate(params[:login], params[:password])
    if <%= user_singular_name %>
      session[:<%= user_singular_name %>_id] = <%= user_singular_name %>.id
      flash[:notice] = I18n.t('authlogic.actions.login.notice', :default => 'Logged in successfully.')
      redirect_to_target_or_default(root_url)
    else
      flash.now[:alert] = I18n.t('authlogic.actions.login.alert', :default => 'Invalid login or password.')
      render :action => 'new'
    end
  end
  
  def destroy
    session[:<%= user_singular_name %>_id] = nil
    flash[:notice] = I18n.t('authlogic.actions.logout.notice', :default => 'You have been logged out.')
    redirect_to root_url
  end
<%- end -%>
end
