class SessionsController < ApplicationController

  # before_filter CASClient::Frameworks::Rails::Filter will redirect users to the CAS login page if not logged in
  # Upon success, it will redirect users back to application 'index' action page, which the CASClient filter will
  # then set the session[:cas_user]
  # Upon logout, the the CASClient filter will reset the session[:cas_user] to nil via the destroy action

  before_filter CASClient::Frameworks::Rails::Filter, :except => [:new,:destroy,:create]

  def index
    redirect_to surveys_path
  end
  def new
    redirect_to surveys_path if logged_in?
  end
  def create
    CASClient::Frameworks::Rails::Filter.filter(self)
  end
  def destroy
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
end
