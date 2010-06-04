class <%= session_class_name %> < Authlogic::Session::Base
  consecutive_failed_logins_limit 15 # Default: 50
  failed_login_ban_for 2.hours # Default: 2.hours, set to 0 for permanent ban
  
end
