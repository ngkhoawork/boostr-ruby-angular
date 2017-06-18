require 'representable/xml'

class Operative::CustomFieldsRepresenter < Representable::Decorator
  include Representable::XML

  self.representation_wrap = 'v2:customFields'

  property :location_id_1, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :location_id_2, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :primary_sales_rep_id, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :opportunity_created_date, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :sfdc_type, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :final_billable_customer, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator
  property :ultimate_customer_advertiser, decorator: Operative::CustomFieldRepresenter, exec_context: :decorator

  def location_id_1
    { name: 'Location_ID_1', value: deal_members[0].office } if deal_members[0].office.present?
  end

  def location_id_2
    if deal_members[1].present? && deal_members[1].office.present?
      { name: 'Location_ID_2', value: deal_members[1].office }
    end
  end

  def primary_sales_rep_id
    { name: 'Primary_Sales_Rep_ID', value: deal_members[0].employee_id } if deal_members[0].office.present?
  end

  def opportunity_created_date
    { name: 'Opportunity_Created_Date', value: represented.created_at }
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

  private

  def deal_members
    represented.deal_members.not_account_manager_users.ordered_by_share.map(&:user)
  end
  
  def account_custom_fields
    represented.company.account_cf_names
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

  def deal_type
    @_deal_type ||= Deal.get_option(represented, 'Deal Type')
  end
end
