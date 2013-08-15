class RemoveSchoolIdFromLeads < ActiveRecord::Migration
  def change
    remove_column :leads, :school_id
  end
end
