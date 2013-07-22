ActiveAdmin.register Survey do
  actions :all

  action_item only: :show do
    link_to('Custom Fields', admin_survey_custom_fields_path(resource))
  end
  action_item only: :edit do
    link_to('Associate All Schools With This Survey', associate_all_schools_admin_survey_path(resource), method: :put)
  end
  action_item only: :edit do
    link_to('Remove All Schools From This Survey', remove_all_schools_admin_survey_path(resource), method: :put)
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
    column 'Number of Associated Schools' do |s|
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
    end

    f.inputs "Associated Schools" do
      hint = "Select the schools that should be associated to this survey."
      hint = f.object.new_record? ? hint : "#{ hint } To associate/remove all schools at once use the buttons found at top-right of this screen."
      f.input :schools, as: :check_boxes, collection: School.all.sort_by(&:display_name), hint: hint
    end

    f.actions
  end

  member_action :associate_all_schools, method: :put do
    survey = Survey.find(params[:id])

    survey.schools = School.all
    flash[:notice] = 'Associated all schools with this survey.'

    redirect_to action: :edit
  end

  member_action :remove_all_schools, method: :put do
    survey = Survey.find(params[:id])

    survey.schools = []
    flash[:notice] = 'Removed all schools from this survey.'

    redirect_to action: :edit
  end
end
