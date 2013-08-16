class AddFieldNameToFields < ActiveRecord::Migration
  def change
    add_column :fields, :field_name, :string
  end
end
