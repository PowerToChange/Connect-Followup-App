class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.integer :civicrm_id
      t.integer :pulse_id
      t.string :display_name

      t.timestamps
    end

    create_table :schools_users do |t|
      t.belongs_to :school
      t.belongs_to :user
    end

    create_table :schools_surveys do |t|
      t.belongs_to :school
      t.belongs_to :survey
    end
  end
end
