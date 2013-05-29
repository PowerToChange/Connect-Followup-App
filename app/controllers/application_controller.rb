class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

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

  def authenticate_user!
    redirect_to log_in_path unless logged_in?
  end
end
