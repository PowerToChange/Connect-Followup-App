class RemoveSurveyUsers < ActiveRecord::Migration
  def up
    drop_table :survey_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
