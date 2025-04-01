class CreateActionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :action_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :priority
      t.date :due_date
      t.boolean :completed

      t.timestamps
    end
  end
end
