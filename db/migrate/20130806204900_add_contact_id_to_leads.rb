class AddContactIdToLeads < ActiveRecord::Migration
  def up
    add_column :leads, :contact_id, :integer
    Lead.all.each do |lead|
      lead.update_attribute(:contact_id, lead.response.contact_id)
    end
  end

  def down
    remove_column :leads, :contact_id
  end
end
