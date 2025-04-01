json.extract! product_question, :id, :product_id, :user_id, :asked_by, :question, :answer, :answered_by, :answered_at, :created_at, :updated_at
json.url product_question_url(product_question, format: :json)
