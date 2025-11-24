require "test_helper"

class ProductQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product_question = product_questions(:one)
  end

  test "should get index" do
    get product_questions_url
    assert_response :success
  end

  test "should get new" do
    get new_product_question_url
    assert_response :success
  end

  test "should create product_question" do
    assert_difference("ProductQuestion.count") do
      post product_questions_url, params: { product_question: { answer: @product_question.answer, answered_at: @product_question.answered_at, answered_by: @product_question.answered_by, asked_by: @product_question.asked_by, product_id: @product_question.product_id, question: @product_question.question, user_id: @product_question.user_id } }
    end

    assert_redirected_to product_question_url(ProductQuestion.last)
  end

  test "should show product_question" do
    get product_question_url(@product_question)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_question_url(@product_question)
    assert_response :success
  end

  test "should update product_question" do
    patch product_question_url(@product_question), params: { product_question: { answer: @product_question.answer, answered_at: @product_question.answered_at, answered_by: @product_question.answered_by, asked_by: @product_question.asked_by, product_id: @product_question.product_id, question: @product_question.question, user_id: @product_question.user_id } }
    assert_redirected_to product_question_url(@product_question)
  end

  test "should destroy product_question" do
    assert_difference("ProductQuestion.count", -1) do
      delete product_question_url(@product_question)
    end

    assert_redirected_to product_questions_url
  end
end
