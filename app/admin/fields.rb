ActiveAdmin.register Field do
  belongs_to :survey
  actions :all, :except => [:edit,:update,:destroy,:new,:create]

  index do
    column 'Field' do |f|
      f.field
    end
    column :label
    default_actions
  end
end
