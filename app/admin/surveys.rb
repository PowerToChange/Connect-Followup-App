ActiveAdmin.register Survey do

  action_item :only => :show do
    link_to('Custom Fields', admin_survey_custom_fields_path(resource))
  end

  index do
    column :title
    column :survey_id
    column :campaign_id
    column :activity_type_id
    default_actions
  end

  form do |f|
    f.inputs "Survey Details" do
      f.input :survey_id
      f.input :campaign_id
      f.input :activity_type_id
      f.input :title
    end
    f.actions
  end
end
