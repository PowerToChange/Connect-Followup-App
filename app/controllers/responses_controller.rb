class ResponsesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_survey

  def show
    @contact = Contact.includes(:notes, :activities, :relationships).where(id: params[:contact_id], return: contact_return_fields).first

    @response = Response.initialize_and_preset_by_survey_and_contact_and_activity(@survey, @contact, params[:id])

    @activities = @contact.activities.sort_by(&:activity_date_time).reverse
    @notes = @contact.notes.select { |n| n.note.present? }.sort_by(&:modified_date).reverse

    @rejoiceables_collection = OptionValue.where(option_group_id: OptionGroup::REJOICEABLES_ID, is_active: 1).sort_by(&:value).collect { |ov| [ov.value, ov.label] }
  end

  private

  def get_survey
    @survey = Survey.find(params[:survey_id])
  end

  def contact_return_fields
    (@survey.fields.collect(&:field_name) + [:display_name]).join(',')
  end
end
