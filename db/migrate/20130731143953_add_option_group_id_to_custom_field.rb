class AddOptionGroupIdToCustomField < ActiveRecord::Migration
  def up
    add_column :custom_fields, :option_group_id, :integer
    Survey.all.each { |s| CustomField.sync(s) }
  end

  def down
    remove_column :custom_fields, :option_group_id
  end
end
