require 'representable/xml'

class Operative::CustomFieldsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'v2:customFields'

  property :location_id_1, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :location_id_2, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :primary_sales_rep_id, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :opportunity_created_date, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator, if: !:buzzfeed?
  property :sfdc_type, decorator: Operative::DropdownCustomFieldRepresenter, exec_context: :decorator
  property :final_billable_customer, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :ultimate_customer_advertiser, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :billing_notes, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator, if: :buzzfeed?
  property :country_campaign, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator, if: :buzzfeed?
  property :buzzfeed_signin_entity, decorator: Operative::DropdownCustomFieldRepresenter, exec_context: :decorator, if: :buzzfeed?

  delegate :company, to: :represented

  def location_id_1
    if deal_members[0].present? && deal_members[0].office.present?
      { name: 'Location_ID_1', value: deal_members[0].office }
    end
  end

  def location_id_2
    if deal_members[1].present? && deal_members[1].office.present?
      { name: 'Location_ID_2', value: deal_members[1].office }
    end
  end

  def primary_sales_rep_id
    if deal_members[0].present? && deal_members[0].employee_id.present?
      { name: 'Primary_Sales_Rep_ID', value: deal_members[0].employee_id }
    end
  end

  def opportunity_created_date
    { name: 'Opportunity_Created_Date', value: represented.created_at.strftime('%Y-%m-%d') }
  end

  def sfdc_type
    { name: 'SFDC_Type', value: deal_type } if deal_type.present?
  end

  def final_billable_customer
    if account.account_cf.present? && cf_billable_client_id.present? && account_cf_billable_client_id_value.present?
      { name: 'Final_billable_customer', value: account_cf_billable_client_id_value }
    end
  end

  def ultimate_customer_advertiser
    if represented.advertiser.account_cf.present? && cf_intacct_ultimate_customer_id.present? && advertiser_cf_intacct_ultimate_customer_id_value.present?
      { name: 'Ultimate_customer_advertiser', value: advertiser_cf_intacct_ultimate_customer_id_value }
    end
  end

  def country_campaign
    if (value = custom_field_value('Territory Campaign Will Run In'))
      { name: 'Country_the_campaign_will_run_in__c', value: value }
    end
  end

  def billing_notes
    if (value = custom_field_value('Billing Notes'))
      { name: 'Billing_notes__c', value: value }
    end
  end

  def buzzfeed_signin_entity
    if (value = custom_field_value('BuzzFeed Signing Entity'))
      { name: 'Buzzfeed_signing_entity', value: value }
    end
  end

  private

  def deal_members
    @_deal_members ||= represented.deal_members.not_account_manager_users.ordered_by_share.map(&:user)
  end

  def account_custom_fields
    company.account_cf_names
  end

  def account
    represented.agency.present? ? represented.agency : represented.advertiser
  end

  def cf_billable_client_id
    @_cf_billable_client_id ||= account_custom_fields.find_by(field_label: 'Billable Client ID')
  end

  def account_cf_billable_client_id_value
    account.account_cf.send(cf_billable_client_id.field_name)
  end

  def cf_intacct_ultimate_customer_id
    @_cf_intacct_ultimate_customer_id ||= account_custom_fields.find_by(field_label: 'Intacct Ultimate Customer ID')
  end

  def advertiser_cf_intacct_ultimate_customer_id_value
    represented.advertiser.account_cf.send(cf_intacct_ultimate_customer_id.field_name)
  end

  def custom_field_value(field_label)
    field_name = company.deal_custom_field_names.find_by(field_label: field_label)&.field_name
    represented.deal_custom_field&.send(field_name)
  end

  def deal_type
    @_deal_type ||= Deal.get_option(represented, 'Deal Type')
  end

  def buzzfeed?(options)
    options[:buzzfeed].eql? true
  end
end
