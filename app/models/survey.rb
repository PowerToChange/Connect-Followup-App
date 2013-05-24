class Survey < ActiveRecord::Base
  attr_accessible :activity_type_id, :custom_group_id, :title

  validates_presence_of :activity_type_id

  before_save :sync

  private

  def sync
    survey = CiviCrm::CustomGroup.where(:extends => 'Activity', :extends_entity_column_value => self.activity_type_id).first
    self.custom_group_id = survey.id
    self.title = survey.title
  end
end
