class ProductQuestionsController < ApplicationController
  before_action :set_product_question, only: %i[ show edit update destroy ]

  # GET /product_questions or /product_questions.json
  def index
    @product_questions = ProductQuestion.all
  end

  # GET /product_questions/1 or /product_questions/1.json
  def show
  end

  # GET /product_questions/new
  def new
    @product_question = ProductQuestion.new
  end

  # GET /product_questions/1/edit
  def edit
  end

  # POST /product_questions or /product_questions.json
  def create
    @product_question = ProductQuestion.new(product_question_params)

    respond_to do |format|
      if @product_question.save
        format.html { redirect_to @product_question, notice: "Product question was successfully created." }
        format.json { render :show, status: :created, location: @product_question }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_questions/1 or /product_questions/1.json
  def update
    respond_to do |format|
      if @product_question.update(product_question_params)
        format.html { redirect_to @product_question, notice: "Product question was successfully updated." }
        format.json { render :show, status: :ok, location: @product_question }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_questions/1 or /product_questions/1.json
  def destroy
    @product_question.destroy!

    respond_to do |format|
      format.html { redirect_to product_questions_path, status: :see_other, notice: "Product question was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_question
      @product_question = ProductQuestion.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_question_params
      params.expect(product_question: [ :product_id, :user_id, :asked_by, :question, :answer, :answered_by, :answered_at ])
    end
end
