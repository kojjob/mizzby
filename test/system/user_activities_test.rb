require "application_system_test_case"

class UserActivitiesTest < ApplicationSystemTestCase
  setup do
    @user_activity = user_activities(:one)
  end

  test "visiting the index" do
    visit user_activities_url
    assert_selector "h1", text: "User activities"
  end

  test "should create user activity" do
    visit user_activities_url
    click_on "New user activity"

    fill_in "Activity type", with: @user_activity.activity_type
    fill_in "Color", with: @user_activity.color
    fill_in "Description", with: @user_activity.description
    fill_in "Icon", with: @user_activity.icon
    fill_in "Reference", with: @user_activity.reference_id
    fill_in "Reference type", with: @user_activity.reference_type
    fill_in "Title", with: @user_activity.title
    fill_in "User", with: @user_activity.user_id
    click_on "Create User activity"

    assert_text "User activity was successfully created"
    click_on "Back"
  end

  test "should update User activity" do
    visit user_activity_url(@user_activity)
    click_on "Edit this user activity", match: :first

    fill_in "Activity type", with: @user_activity.activity_type
    fill_in "Color", with: @user_activity.color
    fill_in "Description", with: @user_activity.description
    fill_in "Icon", with: @user_activity.icon
    fill_in "Reference", with: @user_activity.reference_id
    fill_in "Reference type", with: @user_activity.reference_type
    fill_in "Title", with: @user_activity.title
    fill_in "User", with: @user_activity.user_id
    click_on "Update User activity"

    assert_text "User activity was successfully updated"
    click_on "Back"
  end

  test "should destroy User activity" do
    visit user_activity_url(@user_activity)
    accept_confirm { click_on "Destroy this user activity", match: :first }

    assert_text "User activity was successfully destroyed"
  end
end
