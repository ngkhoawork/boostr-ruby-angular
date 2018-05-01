class EalertTemplate::Contract < EalertTemplate::Base
  class << self
    def field_names
      %i(
        description
        advertiser
        agency
        deal
        publisher
        holding_company
        type
        status
        start_date
        end_date
        amount
        days_notice_required
        restricted
        currency
      )
    end

    def subject_class
      Contract
    end

    def subject_decorator_class
      Emails::ContractDecorator
    end
  end
end
