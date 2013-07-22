ActiveAdmin.register School do
  actions :index

  action_item only: :index do
    link_to('Sync All Schools From CiviCrm', sync_all_schools_from_civicrm_admin_schools_path, method: :post, confirm: 'Really?')
  end

  index do
    column :display_name
    column 'CiviCrm ID' do |s|
      s.civicrm_id
    end
    column 'Pulse ID' do |s|
      s.pulse_id
    end
    column :created_at
    column :updated_at
  end

  collection_action :sync_all_schools_from_civicrm, method: :post do
    begin
      School.sync_all_from_civicrm
    rescue => e
      Rails.logger.error "Failed to sync schools from CiviCrm: #{ e }"
      flash[:error] = 'Oops! There was a problem syncing schools from CiviCrm!'
    else
      flash[:notice] = 'Synced schools from CiviCrm.'
    end
    redirect_to action: :index
  end
end