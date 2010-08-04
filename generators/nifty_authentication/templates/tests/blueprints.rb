require 'machinist/active_record'
require 'sham'
require 'forgery'

Role.blueprint do
  name { "user" }
end

User.blueprint do
  username { Forgery::Internet.user_name }
  email { Forgery::Internet.email_address }
  password { Forgery::Basic.password }
  password_confirmation { password }
  password_salt { Authlogic::Random.hex_token }
  persistence_token { Authlogic::Random.hex_token }
  crypted_password { Authlogic::CryptoProviders::Sha512.encrypt(password + password_salt ) }
  perishable_token { Authlogic::Random.friendly_token } # optional, see Authlogic::Session::Perishability
  login_count { 0 }
  failed_login_count { 0 }
  last_request_at { Time.now }
  current_login_at { Time.now }
  last_login_at { Time.now }
#  single_access_token { Authlogic::Random.friendly_token }
end

Assignment.blueprint do
  user
  role
end
