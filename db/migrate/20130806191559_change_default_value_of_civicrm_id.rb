class ChangeDefaultValueOfCivicrmId < ActiveRecord::Migration
  def up
    change_column :users, :civicrm_id, :integer, default: User::DEFAULT_CIVICRM_ID
    User.where(civicrm_id: nil).each { |u| u.update_attribute(:civicrm_id, User::DEFAULT_CIVICRM_ID) }
  end

  def down
    change_column :users, :civicrm_id, :integer, default: nil
  end
end
