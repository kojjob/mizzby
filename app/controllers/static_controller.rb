class StaticController < ApplicationController
  # Include Devise helpers
  include Devise::Controllers::Helpers

  skip_before_action :check_profile_completion, raise: false
  def home
  end

  def contact
  end

  def about
  end

  def help_center
  end

  def privacy_policy
  end

  def term_of_service
  end

  def pricing
  end
end
