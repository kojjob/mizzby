class AdminPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def admin?
    user&.admin? || user&.super_admin?
  end

  def super_admin?
    user&.super_admin?
  end

  # Resource access checks
  def can_manage_users?
    admin?
  end

  def can_create_users?
    super_admin?
  end

  def can_delete_users?
    super_admin?
  end

  def can_manage_products?
    admin?
  end

  def can_delete_products?
    super_admin?
  end

  def can_manage_orders?
    admin?
  end

  def can_manage_categories?
    admin?
  end

  def can_manage_sellers?
    admin?
  end

  def can_approve_sellers?
    admin?
  end

  def can_manage_settings?
    super_admin?
  end

  # Feature access checks
  def can_view_analytics?
    admin?
  end

  def can_access_logs?
    super_admin?
  end

  def can_manage_payments?
    admin?
  end

  def can_issue_refunds?
    super_admin?
  end
end
