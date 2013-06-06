class AddStatusIdToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :status_id, :integer, :default => 4
  end
end
