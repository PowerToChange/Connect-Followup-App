class AddResponsesCountCacheToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :responses_count_cache, :integer
  end
end
