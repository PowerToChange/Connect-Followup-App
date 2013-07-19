module CiviCrmModel
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  module ClassMethods

    def save
      return false unless self.valid?

      begin
        if self.id.present?
          response = self.update(self.attributes)
        else
          response = self.create(self.attributes)
        end
      rescue => e
        puts e
        return false
      end
    end

  end
end
