class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # Enum for status
  enum :status, { unread: 0, read: 1 }

  # Enum for notification_type
  enum :notification_type, {
    info: 0,
    success: 1,
    warning: 2,
    error: 3,
    order: 4,
    payment: 5,
    product: 6,
    system: 7
  }, prefix: :type

  # Validations
  validates :title, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :unread_notifications, -> { where(status: :unread) }

  # Methods
  def mark_as_read
    update(status: :read, read_at: Time.current) if unread?
  end

  def read?
    status == "read" || read_at.present?
  end

  def unread?
    !read?
  end

  # Icon based on notification type
  def icon
    case notification_type
    when "info" then "information-circle"
    when "success" then "check-circle"
    when "warning" then "exclamation"
    when "error" then "x-circle"
    when "order" then "shopping-bag"
    when "payment" then "credit-card"
    when "product" then "cube"
    when "system" then "cog"
    else "bell"
    end
  end

  # Color based on notification type
  def color
    case notification_type
    when "info" then "blue"
    when "success" then "green"
    when "warning" then "yellow"
    when "error" then "red"
    when "order" then "indigo"
    when "payment" then "purple"
    when "product" then "pink"
    when "system" then "gray"
    else "blue"
    end
  end
end
