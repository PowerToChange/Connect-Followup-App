class AddSchoolIdToLeads < ActiveRecord::Migration
  def up
    add_column :leads, :school_id, :integer
    Lead.find_and_preset_all_by_leads(Lead.all).each do |lead|
      lead.update_attribute(:school_id, lead.response.school.try(:id))
    end
  end
  def down
    remove_column :leads, :school_id
  end
end
