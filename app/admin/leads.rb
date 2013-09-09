ActiveAdmin.register Lead, :as => "Connection" do
  actions :index, :show

  filter :response_id, label: 'Activity ID'
  filter :survey, collection: proc { Survey.order('title').all }
  filter :user, collection: proc { User.order('first_name, last_name').all }
  filter :status_id, label: 'Status ID'
  filter :created_at

  index do
    column 'Activity ID' do |l|
      l.response_id
    end
    column :survey
    column :user
    column 'Status' do |l|
      l.status
    end
    column 'Engagement Level' do |l|
      engagement_level_label(l.engagement_level)
    end
    default_actions
  end

  show do |ad|
    attributes_table do
      row :id
      row :user
      row :survey
      row 'Activity ID' do |l|
        l.response_id
      end
      row 'Status' do |l|
        l.status
      end
      row 'Engagement Level' do |l|
        engagement_level_label(l.engagement_level)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
