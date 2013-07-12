ActiveAdmin.register Lead, :as => "Connection" do
  actions :index, :show
  index do
    column 'Activity ID' do |l|
      l.response_id
    end
    column :survey
    column :user
    column :status
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
      row :status
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
