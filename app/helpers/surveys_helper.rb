module SurveysHelper
  def school_options_for_filter_select
    School.all.sort_by(&:display_name).collect do |s|
      [s.display_name, s.civicrm_id]
    end
  end
end