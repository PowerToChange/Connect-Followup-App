class AuthController < ApplicationController
  before_filter :require_login, only: :login

  def login
    if logged_in?
      flash[:notice] = "Welcome, CAS user #{current_user}"
      redirect_to :root
    else
      flash[:error] = "Sorry, we couldn't log you in, please try again!"
      redirect_to :application_welcome
    end
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
end
