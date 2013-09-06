require 'csv'

class ExportsController < ApplicationController
  include ResponsesHelper

  before_filter :authenticate_user!

  def survey
    @survey = Survey.find(params[:id])

    # This special case with school is just for performance reasons
    if params[:export] && params[:export].try(:[], :target_contact_relationship_contact_id_b).present?
      params[:export].merge!(exclude_nested_school: true)
      @school = School.where(civicrm_id: params[:export][:target_contact_relationship_contact_id_b]).first
    end

    @responses = @survey.all_of_the_responses!((params[:export].presence || {}).merge!(return: @survey.fields_to_return_from_civicrm))

    csv = CSV.generate do |csv|
      csv << line_headers_for_survey_export(@survey)
      @responses.each do |response|
        csv << attributes_from_response_to_survey_for_export(response, @survey)
      end
    end

    filename = filename_for_survey_export(@survey)

    send_data csv, filename: filename, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{ filename }"

  rescue => e
    puts e
    Rails.logger.error "Export failed: #{ e }"
    flash[:error] = I18n.t('error')
    redirect_to :back
  end


  private

  def filename_for_survey_export(survey)
    "#{ survey.title.gsub(/[^a-zA-Z0-9]/, '').presence || 'export' }.csv"
  end

  def line_headers_for_survey_export(survey)
    line_headers = [
      # Contact
      'Contact id',
      'Display name',
      'First name',
      'Last name',
      'Gender',
      'Phone',
      'Email',
      'Do not email',
      'Do not phone',
      'Do not sms',
      'Do not mail',
      'Year',
      'Year other',
      'Degree',
      'International',
      'Residence',

      # School
      'School display name',
      'School nick name',

      # Response
      'Survey title',
      'Priority',
      'Status',
      'Engagement level',
      'Submitted at'
    ]

    # Survey custom fields
    @survey_answer_fields ||= survey.fields.answers
    @survey_answer_fields.each do |field|
      line_headers << field.label
    end

    # Lead
    line_headers << "Assigned to"

    line_headers
  end

  def attributes_from_response_to_survey_for_export(response, survey)
    time_start = Time.now

    school = @school.presence || response.school

    Rails.logger.debug("attributes_from_response_to_survey_for_export 1 in #{ (Time.now - time_start) * 1000.0 }ms")

    attributes = [
      # Contact
      response.contact.contact_id,
      response.contact.display_name,
      response.contact.first_name,
      response.contact.last_name,
      gender_label(response.contact.gender_id),
      response.contact.phone,
      response.contact.email,
      boolean_label(response.contact.do_not_email),
      boolean_label(response.contact.do_not_phone),
      boolean_label(response.contact.do_not_sms),
      boolean_label(response.contact.do_not_mail),
      year_label(response.contact.send(CiviCrm.custom_fields.contact.year)),
      response.contact.send(CiviCrm.custom_fields.contact.year_other),
      response.contact.send(CiviCrm.custom_fields.contact.degree),
      response.contact.send(CiviCrm.custom_fields.contact.international),
      response.contact.send(CiviCrm.custom_fields.contact.residence),

      # School
      school.try(:display_name),
      school.try(:nick_name),

      # Response
      survey.title,
      priority_label(response.response.priority_id, true),
      status_label(response.response.status_id),
      engagement_level_label(response.response.engagement_level),
      response.response.activity_date_time
    ]

    Rails.logger.debug("attributes_from_response_to_survey_for_export 2 in #{ (Time.now - time_start) * 1000.0 }ms")

    # Survey custom fields
    @survey_answer_fields ||= survey.fields.answers
    @survey_answer_fields.each do |field|
      attributes << response.build_answer_to_field(field).answer
    end

    Rails.logger.debug("attributes_from_response_to_survey_for_export 3 in #{ (Time.now - time_start) * 1000.0 }ms")

    # Lead
    attributes << response.lead.try(:user).try(:to_s)

    Rails.logger.debug("attributes_from_response_to_survey_for_export 4 done in #{ (Time.now - time_start) * 1000.0 }ms")

    attributes
  end

end
