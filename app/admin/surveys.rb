ActiveAdmin.register Survey do
  actions :all

  action_item only: :show do
    link_to('Survey Fields', admin_survey_fields_path(resource))
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
    column 'Schools' do |s|
      s.schools.count
    end
    column 'Fields' do |s|
      s.fields.count
    end
    default_actions
  end

  show do
    panel "Survey" do
      attributes_table_for survey do
        survey.attributes.keys.each { |column| row column }
      end
    end

    panel "Fields" do
      table_for survey.fields.sort_by(&:field_name) do
        column :field_name
        column :label
      end
    end

    panel "Associated Schools" do
      table_for survey.schools.sort_by(&:display_name) do
        column "School Name" do |school|
          school.display_name
        end
        column :nick_name
        column :civicrm_id
        column :pulse_id
      end
    end
  end

  form do |f|
    f.inputs "Survey Details" do
      f.input :survey_id, label: 'Survey ID', hint: 'Enter the survey id from CiviCrm, other attributes will be synced from CiviCrm based on this id.'
      f.input :has_all_schools, hint: "Always associate this survey with every school. #{ f.object.new_record? ? 'After you create the survey you may associate it with a few specific schools.' : '' }"
    end

    if !f.object.has_all_schools? && !f.object.new_record?
      f.inputs "Associated Schools" do
        f.input :schools, as: :check_boxes, collection: School.all.sort_by(&:display_name), hint: "Select the schools that should be associated to this survey."
      end
    end

    f.actions
  end

end
