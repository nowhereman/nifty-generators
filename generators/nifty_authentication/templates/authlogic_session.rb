class <%= session_class_name %> < Authlogic::Session::Base
  consecutive_failed_logins_limit 15 # Default: 50
  failed_login_ban_for 2.hours # Default: 2.hours, set to 0 for permanent ban

  # We reset Authorization.current_user back to GuestUser after UserSession.destroy
  # because current_user_session.record will be set nil.
  after_destroy :set_current_user_for_model_security

  protected

  def set_current_user_for_model_security
    ::Authorization.current_user = record
  end
end
