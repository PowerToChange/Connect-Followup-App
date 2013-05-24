class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.belongs_to :survey
      t.integer :custom_field_id
      t.string :label

      t.timestamps
    end
    add_index :custom_fields, :survey_id
  end
end
