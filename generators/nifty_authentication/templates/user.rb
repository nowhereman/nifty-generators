class <%= user_class_name %> < ActiveRecord::Base
<%- if options[:authlogic] -%>
  acts_as_authentic
  <%- if options[:declarative_authorization] -%>
  has_many :assignments
  has_many :roles, :through => :assignments
  
  def role_symbols
    roles.map do |role|
      role.name.underscore.to_sym
    end
  end

  # Since UserSession.find and UserSession.save will trigger
  # record.save_without_session_maintenance(false) and the 'updated_at', 'last_request_at'
  # fields of user model will be updated every time by authlogic if record (user) found.
  # We need to reset Authorization.current_user instead of giving the update privilege
  # of user model to guest role, and use before_save filter in user model instead of
  # after_find and before_save filters in UserSession model in case of other methods like
  # reset_perishable_token! will call save_without_session_maintenance too.
  before_save :set_current_user_for_model_security
  
  protected

  def set_current_user_for_model_security
    ::Authorization.current_user = self if valid?
  end
  <%- end -%>
<%- else -%>
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation
  
  attr_accessor :password
  before_save :prepare_password
  
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => I18n.t('authlogic.error_messages.login_invalid')
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  
  # login can be either username or email address
  def self.authenticate(login, pass)
    <%= user_singular_name %> = find_by_username(login) || find_by_email(login)
    return <%= user_singular_name %> if <%= user_singular_name %> && <%= user_singular_name %>.matching_password?(pass)
  end
  
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end
  
  private
  
  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
<%- end -%>
end
