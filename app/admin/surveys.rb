ActiveAdmin.register Survey do
  actions :all, :except => [:edit,:update]
  action_item :only => :show do
    link_to('Custom Fields', admin_survey_custom_fields_path(resource))
  end

  index do
    column :title
    column 'Survey ID' do |l|
      l.survey_id
    end
    column 'Campaign ID' do |l|
      l.campaign_id
    end
    column 'Activity Type ID' do |l|
      l.activity_type_id
    end
    default_actions
  end

  form do |f|
    f.inputs "Survey Details" do
      f.input :survey_id, :label => 'Survey ID'
    end
    f.actions
  end
end
