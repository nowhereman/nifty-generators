class Assignment < ActiveRecord::Base
  using_access_control

  belongs_to :user
  belongs_to :role

  validates_uniqueness_of :user_id, :scope => :role_id
  
end