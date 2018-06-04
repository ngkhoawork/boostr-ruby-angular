module SpendAgreements
  class InfoMessageBuilder < BaseService
    def perform
      return if excluded_objects.blank?
      case message_context
      when :deal
        deal_message_template
      when :agreement
        agreement_message_template
      else
        return
      end
    end

    private

    def excluded_objects
      if before_track
        before_track - after_track
      end
    end

    def deal_message_template
      {excluded_objects: excluded_objects}
    end

    def agreement_message_template
      {excluded_objects: excluded_objects}
    end
  end
end
