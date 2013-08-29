ActiveAdmin.register Field do
  belongs_to :survey
  actions :all, :except => [:edit,:update,:destroy,:new,:create]

  index do
    column :field_name
    column :label
    column :custom_field_id
    column :option_group_id
    default_actions
  end
end
