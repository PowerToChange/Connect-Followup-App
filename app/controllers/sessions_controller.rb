class SessionsController < ApplicationController

  # before_filter CASClient::Frameworks::Rails::Filter will redirect users to the CAS login page if not logged in
  # Upon success, it will redirect users back to application 'index' action page, which the CASClient filter will
  # then set the session[:cas_user]
  # Upon logout, the the CASClient filter will reset the session[:cas_user] to nil via the destroy action

  before_filter CASClient::Frameworks::Rails::Filter, :except => [:new,:destroy,:create]
  before_filter :authenticate_user!, :only => :index

  def index
    redirect_to connections_path
  end
  def new
    if cas_logged_in?
      flash.now[:alert] = "Login failed! No associating user account found for your CAS account. Please contact your administrator for assistance."
    end
    redirect_to connections_path if logged_in?
  end
  def create
    CASClient::Frameworks::Rails::Filter.filter(self)
  end
  def destroy
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
end
