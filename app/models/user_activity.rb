class UserActivity < ApplicationRecord
  belongs_to :user
  belongs_to :reference, polymorphic: true
end
