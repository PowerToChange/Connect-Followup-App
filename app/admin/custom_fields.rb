ActiveAdmin.register CustomField do
  belongs_to :survey
  actions :all, :except => [:edit,:update,:destroy,:new,:create]

  index do
    column 'Custom Field ID' do |f|
      f.custom_field_id
    end
    column :label
    default_actions
  end
end
