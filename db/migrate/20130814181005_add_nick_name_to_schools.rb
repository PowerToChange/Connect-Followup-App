class AddNickNameToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :nick_name, :string
  end
end
