class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.belongs_to :user
      t.belongs_to :survey
      t.string :response_id

      t.timestamps
    end
    add_index :leads, :user_id
    add_index :leads, :survey_id
  end
end
