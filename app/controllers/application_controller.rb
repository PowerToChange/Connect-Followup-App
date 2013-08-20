class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?, :cas_logged_in?

  before_filter :set_locale
  after_filter :flash_to_headers


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
    @current_user ||= User.where(guid: session[:cas_extra_attributes][:ssoGuid]).first_or_create if cas_logged_in? && session[:cas_extra_attributes]
  end


  private

  def set_locale
    # For manual override
    if params[:locale]
      I18n.locale = params[:locale]
    else
      # Set locale automatically from user agent
      logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
      I18n.locale = extract_locale_from_accept_language_header
      logger.debug "* Locale set to '#{I18n.locale}'"
    end
  end

  def extract_locale_from_accept_language_header
    return I18n.default_locale.to_s unless request.env['HTTP_ACCEPT_LANGUAGE'].present?
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def authenticate_user!
    redirect_to log_in_path unless logged_in?
  end

  # This is used to display flash messages on ajax requests
  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash_message
    response.headers["X-Message-Type"] = flash_type.to_s

    # Prevents flash from appearing after page reload.
    # Side-effect: flash won't appear after a redirect.
    # Comment-out if you use redirects.
    flash.discard
  end

  def flash_message
    [:error, :warning, :notice, :success].each do |type|
      return flash[type] unless flash[type].blank?
    end
    return ''
  end

  def flash_type
    [:error, :warning, :notice, :success].each do |type|
      return type unless flash[type].blank?
    end
  end
end
