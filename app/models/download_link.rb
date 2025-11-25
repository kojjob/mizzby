class DownloadLink < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :order

  # Scopes
  scope :active, -> { where(active: true).where("expires_at > ? OR expires_at IS NULL", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :available, -> { active.where("download_count < download_limit OR download_limit IS NULL") }

  # Check if download is still valid
  def valid_for_download?
    active? && !expired? && !limit_reached?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def limit_reached?
    download_limit.present? && download_count.to_i >= download_limit
  end

  def remaining_downloads
    return nil unless download_limit.present?
    [download_limit - download_count.to_i, 0].max
  end

  def days_until_expiry
    return nil unless expires_at.present?
    ((expires_at - Time.current) / 1.day).ceil
  end

  def increment_download!
    increment!(:download_count)
  end
end
