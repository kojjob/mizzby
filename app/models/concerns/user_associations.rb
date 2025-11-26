module UserAssociations
  extend ActiveSupport::Concern

  included do
    # Active Storage for profile picture
    has_one_attached :profile_picture

    # Customer relationships
    has_one  :cart, dependent: :destroy
    has_many :cart_items, dependent: :destroy
    has_many :orders, dependent: :restrict_with_error
    has_many :reviews, dependent: :nullify
    has_many :wishlist_items, dependent: :destroy
    has_many :download_links, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :payment_audit_logs, dependent: :nullify
    has_many :user_activities, dependent: :destroy
    has_many :action_items, dependent: :destroy
    has_many :addresses, dependent: :destroy
    has_many :payment_methods, dependent: :destroy

    # Seller relationship
    has_one :seller, dependent: :destroy
  end
end
