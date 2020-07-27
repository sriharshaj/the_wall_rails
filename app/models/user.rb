class User < ApplicationRecord
  include ModelUtils

  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  has_many :posts, dependent: :destroy
end
