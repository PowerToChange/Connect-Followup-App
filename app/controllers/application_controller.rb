class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?, :cas_logged_in?

  def screen
    @page_title = "Screen #{params[:screen]}"
    render "screen#{params[:screen]}"
  end

  def logged_in?
    current_user.present?
  end

  def cas_logged_in?
    session[:cas_user]
  end

  def current_user
    if cas_logged_in? && session[:cas_extra_attributes] && session[:cas_extra_attributes][:ssoGuid].present?
      @current_user ||= User.where(guid: session[:cas_extra_attributes][:ssoGuid]).first_or_create
    else
      nil
    end
  end

  private

  def authenticate_user!
    redirect_to log_in_path unless logged_in?
  end
end
