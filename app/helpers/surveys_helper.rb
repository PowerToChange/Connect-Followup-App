module SurveysHelper
  def filter_select_for_attribute(f, attribute, options = {})
    f.input attribute, {
      collection: options_for_filter_select_for_attribute(attribute),
      selected: params[:filters].try(:[], attribute),
      include_blank: t('all'),
      required: false,
      label: attribute }.merge(options)
  end

  def field_text_field_for_attribute(f, attribute, options = {})
    f.input attribute, {
      required: false,
      input_html: { value: params[:filters].try(:[], attribute) },
      label: attribute }.merge(options)
  end

  def options_for_filter_select_for_attribute(attribute)
    case attribute.to_sym
    when :target_contact_relationship_contact_id_b
      school_options_for_filter_select
    when :priority_id
      Response.PRIORITIES
    when :target_contact_gender_id
      Response.GENDERS
    when :target_contact_created_date_between
      semester_options_for_filter_select
    when :assignee_contact_id
      [[I18n.t('unassigned'), 'NULL']]
    else # custom fields
      field = Field.where(field_name: attribute).first
      field.present? ? field.option_values_to_select_options : []
    end
  end

  def school_options_for_filter_select
    schools_associated_to_current_user_and_to_survey.sort_by(&:display_name).collect do |s|
      [s.display_name, s.civicrm_id]
    end
  end

  def current_filters_description(count = false)
    if count != false
      current_filter_count = count < CiviCrm.default_row_count ? t('filters.showing_count_contacts_html', count: count) : t('filters.showing_count_contacts_of_many_html', count: count)
      return "#{ current_filter_count }." unless params[:filters].present?
    else
      return '' unless params[:filters].present?
    end

    current_filter_values = params[:filters].collect do |filter, value|
      label = label_from_options_for_value options_for_filter_select_for_attribute(filter), value
      label = label.presence || value.presence
      next unless label.present?

      filter_desc = case filter.to_sym
      when :target_contact_relationship_contact_id_b
        t('school')
      when :priority_id
        t('followup_priority')
      when :target_contact_gender_id
        t('gender')
      when :target_contact_created_date_between
        t('semester')
      when :target_contact_first_name
        t('first_name')
      when :target_contact_last_name
        t('last_name')
      else # custom fields
        Field.where(field_name: filter.to_sym).first.try(:label)
      end

      "#{ filter_desc } <strong><i>#{ label }</i></strong>".strip
    end
    current_filter_values = current_filter_values.compact.to_sentence
    current_filter_values = current_filter_values.present? ? t('filters.showing_contacts_with_filter', filter: current_filter_values) : ''

    showing_contacts = current_filter_count.present? ? current_filter_count : t('filters.showing_contacts')
    "#{ showing_contacts }#{ current_filter_values.present? ? " #{ current_filter_values }." : '.' }"
  end

  def label_from_options_for_value(options, value)
    options.select { |o| o[1].to_s == value.to_s }.try(:first).try(:[], 0)
  end

  def add_delete_lead_button_id(id)
    "add-release-response-#{ id }"
  end
  
  def semester_name(time)
    case time.month
      when 1..5 then t('winter') + ' ' + time.year.to_s
      when 6..8 then t('summer') + ' ' + time.year.to_s
      when 9..12 then t('fall') + ' ' + time.year.to_s
    end
  end
  
  def semester_between_dates(time)
    y = time.year.to_s
    case time.month
      when 1..5 then "#{y}0101000000-#{y}0601000000"
      when 6..8 then "#{y}0601000000-#{y}0901000000"
      when 9..12 then "#{y}0901000000-#{y}1231235959"
    end    
  end
  
  def semester_go_back(time)
    case time.month
    when 1..5 then Time.new(time.year - 1, 9, 1, 0, 0, 0)
      when 6..8 then Time.new(time.year, 1, 1, 0, 0, 0)
      when 9..12 then Time.new(time.year, 6, 1, 0, 0, 0)
    end    
  end
  
  
  def semester_options_for_filter_select
    time = Time.new

    # add current semester
    semester_options = [ [semester_name(time), semester_between_dates(time)] ]
    
    # add 5 previous semesters
    for i in 1..5
      time = semester_go_back(time)
      semester_options << [semester_name(time), semester_between_dates(time)]
    end
    
    semester_options
  end
end