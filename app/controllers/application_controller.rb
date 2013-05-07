class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_login, except: [:welcome]
  before_filter CASClient::Frameworks::Rails::Filter, except: :welcome

  helper_method :current_user, :logged_in?

  def welcome
    redirect_to :root if logged_in?
  end

  def index
  end

  def screen
    @page_title = "Screen #{params[:screen]}"
    render "screen#{params[:screen]}"
  end

  def logged_in?
    current_user.present?
  end

  def current_user
    @current_user ||= session[:cas_user]
  end

  private

  def require_login
    redirect_to :application_welcome unless logged_in?
  end
end
