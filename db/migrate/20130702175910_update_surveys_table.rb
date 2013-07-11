class UpdateSurveysTable < ActiveRecord::Migration
  def up
    add_column :surveys, :survey_id, :integer
    add_column :surveys, :campaign_id, :integer
    remove_column :surveys, :custom_group_id
  end

  def down
    remove_column :surveys, :survey_id
    remove_column :surveys, :campaign_id
    add_column :surveys, :custom_group_id, :integer
  end
end
