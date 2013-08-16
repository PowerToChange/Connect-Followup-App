class RenameCustomFieldsToFields < ActiveRecord::Migration
  def self.up
    rename_table :custom_fields, :fields
  end
  def self.down
    rename_table :fields, :custom_fields
  end
end
