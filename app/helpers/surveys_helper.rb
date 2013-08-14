module SurveysHelper
  def filter_input_for_attribute(f, attribute, options = {})
    f.input attribute, {
      collection: options_for_filter_select_for_attribute(attribute),
      selected: params[:filters].try(:[], attribute),
      include_blank: 'All',
      required: false,
      label: attribute }.merge(options)
  end

  def options_for_filter_select_for_attribute(attribute)
    case attribute.to_sym
    when :target_contact_relationship_contact_id_b
      school_options_for_filter_select
    when :priority_id
      Response::PRIORITIES
    when :target_contact_gender_id
      Response::GENDERS
    when :custom_57
      Response::YEARS
    else
      []
    end
  end

  def school_options_for_filter_select
    current_user.schools.sort_by(&:display_name).collect do |s|
      [s.display_name, s.civicrm_id]
    end
  end

  def current_filters_description
    return '' unless params[:filters].present?

    current_filter_values = params[:filters].collect do |filter, value|
      label = label_from_options_for_value options_for_filter_select_for_attribute(filter), value

      case filter.to_sym
      when :target_contact_relationship_contact_id_b
        "campus #{ label }"
      when :priority_id
        "priority #{ label }"
      when :target_contact_gender_id
        "gender #{ label }"
      when :custom_57
        "year #{ label }"
      else
        label
      end if label.present?
    end

    current_filter_values = current_filter_values.compact.to_sentence
    current_filter_values.present? ? "Showing contacts with #{ current_filter_values }." : ''
  end

  def label_from_options_for_value(options, value)
    options.select { |o| o[1].to_s == value.to_s }.try(:first).try(:[], 0)
  end

  def add_delete_lead_button_id(id)
    "add-release-response-#{ id }"
  end
end