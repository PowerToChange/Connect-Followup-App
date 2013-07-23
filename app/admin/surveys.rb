ActiveAdmin.register Survey do
  actions :all

  action_item only: :show do
    link_to('Custom Fields', admin_survey_custom_fields_path(resource))
  end

  index do
    column :title
    column 'Survey ID' do |s|
      s.survey_id
    end
    column 'Campaign ID' do |s|
      s.campaign_id
    end
    column 'Activity Type ID' do |s|
      s.activity_type_id
    end
    column 'Has All Schools' do |s|
      s.has_all_schools
    end
    column 'Number Of Schools' do |s|
      s.schools.count
    end
    default_actions
  end

  show do
    panel "Survey" do
      attributes_table_for survey do
        survey.attributes.keys.each { |column| row column }
      end
    end

    panel "Associated Schools" do
      table_for survey.schools.sort_by(&:display_name) do
        column "School Name" do |school|
          school.display_name
        end
      end
    end
  end

  form do |f|
    f.inputs "Survey Details" do
      f.input :survey_id, label: 'Survey ID', hint: 'Enter the survey id from CiviCrm, other attributes will be synced from CiviCrm based on this id.'
      f.input :has_all_schools, hint: 'Always associate this survey with every school.'
    end

    unless f.object.has_all_schools?
      f.inputs "Associated Schools" do
        f.input :schools, as: :check_boxes, collection: School.all.sort_by(&:display_name), hint: "Select the schools that should be associated to this survey."
      end
    end

    f.actions
  end

end
