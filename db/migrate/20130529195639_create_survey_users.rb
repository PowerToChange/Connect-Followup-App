class CreateSurveyUsers < ActiveRecord::Migration
  def change
    create_table :survey_users do |t|
      t.belongs_to :user
      t.belongs_to :survey

      t.timestamps
    end
    add_index :survey_users, :user_id
    add_index :survey_users, :survey_id
  end
end
