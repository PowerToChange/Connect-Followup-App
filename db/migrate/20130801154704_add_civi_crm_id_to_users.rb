class AddCiviCrmIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :civicrm_id, :integer
  end
end
