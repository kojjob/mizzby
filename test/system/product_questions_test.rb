require "application_system_test_case"

class ProductQuestionsTest < ApplicationSystemTestCase
  setup do
    @product_question = product_questions(:one)
  end

  test "visiting the index" do
    visit product_questions_url
    assert_selector "h1", text: "Product questions"
  end

  test "should create product question" do
    visit product_questions_url
    click_on "New product question"

    fill_in "Answer", with: @product_question.answer
    fill_in "Answered at", with: @product_question.answered_at
    fill_in "Answered by", with: @product_question.answered_by
    fill_in "Asked by", with: @product_question.asked_by
    fill_in "Product", with: @product_question.product_id
    fill_in "Question", with: @product_question.question
    fill_in "User", with: @product_question.user_id
    click_on "Create Product question"

    assert_text "Product question was successfully created"
    click_on "Back"
  end

  test "should update Product question" do
    visit product_question_url(@product_question)
    click_on "Edit this product question", match: :first

    fill_in "Answer", with: @product_question.answer
    fill_in "Answered at", with: @product_question.answered_at.to_s
    fill_in "Answered by", with: @product_question.answered_by
    fill_in "Asked by", with: @product_question.asked_by
    fill_in "Product", with: @product_question.product_id
    fill_in "Question", with: @product_question.question
    fill_in "User", with: @product_question.user_id
    click_on "Update Product question"

    assert_text "Product question was successfully updated"
    click_on "Back"
  end

  test "should destroy Product question" do
    visit product_question_url(@product_question)
    accept_confirm { click_on "Destroy this product question", match: :first }

    assert_text "Product question was successfully destroyed"
  end
end
