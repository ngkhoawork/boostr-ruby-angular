class CustomFieldNamesQuery < BaseQuery
  def perform
    default_relation
      .for_model(model_name)
      .by_company_id(options[:company_id])
      .by_show_on_modal(options[:show_on_modal])
  end

  private

  def default_relation
    CustomFieldName.all.extending(Scopes)
  end

  def model_name
    options[:subject_type]&.classify
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(company_id: company_id)
    end

    def by_show_on_modal(show_on_modal)
      show_on_modal.nil? ? self : where(show_on_modal: show_on_modal)
    end
  end
end
