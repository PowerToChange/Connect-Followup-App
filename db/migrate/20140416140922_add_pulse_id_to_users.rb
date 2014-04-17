class AddPulseIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pulse_id, :integer
  end
end
