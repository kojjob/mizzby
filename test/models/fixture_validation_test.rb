require "test_helper"

class FixtureValidationTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    User.all.each do |user|
      assert user.valid?, "User #{user.email} is invalid: #{user.errors.full_messages.join(', ')}"
    end
  end
end
