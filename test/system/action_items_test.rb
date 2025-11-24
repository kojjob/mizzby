require "application_system_test_case"

class ActionItemsTest < ApplicationSystemTestCase
  setup do
    @action_item = action_items(:one)
  end

  test "visiting the index" do
    visit action_items_url
    assert_selector "h1", text: "Action items"
  end

  test "should create action item" do
    visit action_items_url
    click_on "New action item"

    check "Completed" if @action_item.completed
    fill_in "Description", with: @action_item.description
    fill_in "Due date", with: @action_item.due_date
    fill_in "Priority", with: @action_item.priority
    fill_in "Title", with: @action_item.title
    fill_in "User", with: @action_item.user_id
    click_on "Create Action item"

    assert_text "Action item was successfully created"
    click_on "Back"
  end

  test "should update Action item" do
    visit action_item_url(@action_item)
    click_on "Edit this action item", match: :first

    check "Completed" if @action_item.completed
    fill_in "Description", with: @action_item.description
    fill_in "Due date", with: @action_item.due_date
    fill_in "Priority", with: @action_item.priority
    fill_in "Title", with: @action_item.title
    fill_in "User", with: @action_item.user_id
    click_on "Update Action item"

    assert_text "Action item was successfully updated"
    click_on "Back"
  end

  test "should destroy Action item" do
    visit action_item_url(@action_item)
    accept_confirm { click_on "Destroy this action item", match: :first }

    assert_text "Action item was successfully destroyed"
  end
end
