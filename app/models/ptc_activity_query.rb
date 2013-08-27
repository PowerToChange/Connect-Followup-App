# PtcActivityQuery is a custom-built CiviCrm API method
# Features of this API method include:
#   - filter responses by particular attributes
#   - return nested entities that are associated to the root entity

class PtcActivityQuery < CiviCrm::BaseResource
  entity :PtcActivityQuery

  class << self

    def find_response_for_survey(id, survey)
      activity = self.where(id: id).where(params_to_return_everything_about_a_contact_for_survey(survey)).first
      Response.new(survey, activity)
    end

    def where_survey(params, survey)
      self.where(params.merge!(params_to_find_responses_to_survey(survey)).merge!(params_to_return_school))
    end

    def params_to_find_responses_to_survey(survey)
      {
        # These three params are used in conjunction to request responses to a particular survey
        campaign_id: survey.campaign_id,
        activity_type_id: ActivityType::PETITION_TYPE_ID,
        source_record_id: survey.survey_id
      }
    end

    def params_to_return_school
      {
        entities: 'target_contact,relationships',
        target_contact_relationship_type_id: Relationship::SCHOOL_CURRENTLY_ATTENDING_TYPE_ID
      }
    end

    def params_to_return_everything_about_a_contact_for_survey(survey)
      {
        entities: 'target_contact,relationships,notes,activities',
        return: contact_return_fields(survey)
      }
    end

    private

    def contact_return_fields(survey)
      extra_fields = [
        :display_name,
        CiviCrm.custom_fields.activity.rejoiceable.rejoiceable_id,
        CiviCrm.custom_fields.activity.rejoiceable.survey_id,
        CiviCrm.custom_fields.contact.year,
        CiviCrm.custom_fields.contact.degree,
        CiviCrm.custom_fields.contact.international
      ]
      (survey.fields.collect(&:field_name) + extra_fields).join(',')
    end

  end
end