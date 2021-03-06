class SessionsController < ApplicationController

  # before_filter CASClient::Frameworks::Rails::Filter will redirect users to the CAS login page if not logged in
  # Upon success, it will redirect users back to application 'index' action page, which the CASClient filter will
  # then set the session[:cas_user]
  # Upon logout, the the CASClient filter will reset the session[:cas_user] to nil via the destroy action

  before_filter CASClient::Frameworks::Rails::Filter, except: [:new, :destroy]
  before_filter :authenticate_user!, :after_login, only: :index

  def index
    redirect_to connections_path if logged_in?
  end

  def new
    redirect_to connections_path if logged_in?
  end

  def create
    redirect_to connections_path if logged_in?
  end

  def destroy
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  private

  def after_login
    update_current_user_from_cas_session
    sync_current_user_from_pulse
  end

  def update_current_user_from_cas_session
    return false unless session[:cas_user].present?
    current_user.update_attributes(email: session[:cas_user],
                                   first_name: session[:cas_extra_attributes].try(:[], :firstName),
                                   last_name: session[:cas_extra_attributes].try(:[], :lastName))
  end

  def sync_current_user_from_pulse
    current_user.sync_from_pulse
  end

end
