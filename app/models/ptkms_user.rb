class PtkmsUser < ApplicationRecord
  # password_digest用
  has_secure_password
  
  validates :name, presence: true, uniqueness: true  
end
