class CreateProductQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :product_questions do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :asked_by
      t.text :question
      t.text :answer
      t.string :answered_by
      t.datetime :answered_at

      t.timestamps
    end
  end
end
