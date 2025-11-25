class Vote < ApplicationRecord
  belongs_to :user

  validates :country_code, presence: true
  validates :user_id, uniqueness: true
end
