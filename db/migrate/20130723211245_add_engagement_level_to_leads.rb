class AddEngagementLevelToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :engagement_level, :string
  end
end
