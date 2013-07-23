class AddHasAllSchoolsToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :has_all_schools, :boolean, default: false
  end
end
