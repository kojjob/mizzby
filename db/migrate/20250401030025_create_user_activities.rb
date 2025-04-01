class CreateUserActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :user_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :activity_type
      t.string :title
      t.text :description
      t.string :icon
      t.string :color
      t.references :reference, polymorphic: true, null: false

      t.timestamps
    end
  end
end
