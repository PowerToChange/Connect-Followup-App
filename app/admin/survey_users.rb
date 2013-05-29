ActiveAdmin.register SurveyUser do
  index do
    column :user do |su|
      su.user.email
    end
    column :survey do |su|
      su.survey.title
    end
    default_actions
  end
end
