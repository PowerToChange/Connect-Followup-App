ActiveAdmin.register Survey do

  action_item :only => :show do
    link_to('Custom Fields', admin_survey_custom_fields_path(resource))
  end

  index do
    column :activity_type_id
    column :custom_group_id
    column :title
    default_actions
  end

  form do |f|
    f.inputs "Survey Details" do
      f.input :activity_type_id
      f.input :custom_group_id
      f.input :title
    end
    f.actions
  end
end
