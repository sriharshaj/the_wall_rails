class Post < ApplicationRecord
  include ModelUtils

  validates :body, presence: true
  belongs_to :user
end
