class ApplicationController < ActionController::Base
  include ApplicationHelper

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

  def filters(default_show_all = false)
    if params[:filters].present?
      # Select only filters that are not blank
      params[:filters] = (params[:filters].presence || {}).select { |_, value| value.present? }
      # Store filters in cookies
      params[:filters].each { |key, value| cookies[filter_cookie_key(key)] = value }

    else
      # If we're not filtering at all then apply a default filter
      params[:filters] = default_filter(default_show_all)
    end

    params[:filters]
  end



  private

  def default_filter(default_show_all = false)
    return {} if default_show_all

    # We want to limit the default result set
    filter = { target_contact_relationship_contact_id_b: cookies[filter_cookie_key(:target_contact_relationship_contact_id_b)] }

    if filter[:target_contact_relationship_contact_id_b].blank?
      filter[:target_contact_relationship_contact_id_b] = schools_associated_to_current_user_and_to_survey.sort_by(&:display_name).first.try(:civicrm_id)
    end
    
    if filter[:target_contact_created_date_between].blank?
      filter[:target_contact_created_date_between] = semester_default_between_dates
    end

    filter
  end

  def semester_default_between_dates
    time = Time.new
    the_semester = nil
    case time.month
      when 1..4 then the_semester = :winter
      when 5..8 then
        if time.month < 8 && time.day < 15 
          the_semester = :summer
        else 
          the_semester = :fall
        end
      when 9..12 then the_semester = :fall
    end
    
    y = time.year.to_s
    case the_semester
      when :winter then "#{y}0101000000-#{y}0501000000"
      when :summer then "#{y}0501000000-#{y}0815000000"
      when :fall then "#{y}0815000000-#{y}1231235959"
    end    
  end

  def filter_cookie_key(filter)
    key = "filter_#{ filter }"
    key = "#{ key }_for_controller_#{ controller_name }"
    key = "#{ key }_survey_#{ @survey.id }" if @survey.present?
    key = "#{ key }_v2" # add versioning to expire old cookies
    key
  end

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
    unless logged_in?
      redirect_to log_in_path
      return false
    end
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
