class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :activity_type_id
      t.string :title
      t.integer :custom_group_id

      t.timestamps
    end
    add_index :surveys, :activity_type_id
    add_index :surveys, :custom_group_id
  end
end
