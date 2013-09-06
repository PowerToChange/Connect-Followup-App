require 'csv'

class ExportsController < ApplicationController
  include ResponsesHelper

  before_filter :authenticate_user!

  def survey
    @survey = Survey.find(params[:id])

    Rails.logger.debug("=============== In ExportsController#survey for survey #{ @survey.id } #{ @survey.title }...")

    if params[:export][:target_contact_relationship_contact_id_b].present?
      params[:export].merge!(exclude_nested_school: true) # for performance reasons
      @school = School.where(civicrm_id: params[:export][:target_contact_relationship_contact_id_b]).first
    end
    @responses = @survey.all_of_the_responses!(params[:export].merge!(return: @survey.fields_to_return_from_civicrm))

    Rails.logger.debug("=============== Generating CSV for survey #{ @survey.id } #{ @survey.title }...")
    csv = CSV.generate do |csv|
      csv << line_headers_for_survey_export(@survey)
      @responses.each do |response|
        Rails.logger.debug("=============== Adding response to CSV #{ response.response_id } #{ response.contact_id } for survey #{ @survey.id } #{ @survey.title }...")
        csv << attributes_from_response_to_survey_for_export(response, @survey)
      end
    end

    filename = filename_for_survey_export(@survey)

    Rails.logger.debug("=============== Returning from ExportsController#survey for survey #{ @survey.id } #{ @survey.title }")
    send_data csv, filename: filename, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{ filename }"

  rescue => e
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
    school = @school.presence || response.school

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

    # Survey custom fields
    @survey_answer_fields ||= survey.fields.answers
    @survey_answer_fields.each do |field|
      attributes << response.build_answer_to_field(field).answer
    end

    # Lead
    attributes << response.lead.try(:user).try(:to_s)

    attributes
  end

end
