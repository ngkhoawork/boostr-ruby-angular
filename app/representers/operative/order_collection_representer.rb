require 'representable/xml'

class Operative::OrderCollectionRepresenter < Representable::Decorator
  include Representable::XML
  include ActionView::Helpers::NumberHelper

  self.representation_wrap = :salesOrder

  property :sales_order_type, as: :name, exec_context: :decorator, wrap: :salesOrderType,
           if: -> (options) { options[:enable_operative_extra_fields].eql?(false) && options[:buzzfeed].eql?(false) }
  property :mashable_sales_order_type, as: :name, exec_context: :decorator, wrap: :salesOrderType,
           if: -> (options) { options[:enable_operative_extra_fields].eql?(true) && options[:buzzfeed].eql?(false) }
  property :buzzfeed_order_type, as: :name, exec_context: :decorator, wrap: :salesOrderType,
           if: -> (options) { options[:buzzfeed].eql?(true) }

  property :alternate_id, as: :alternateId, exec_context: :decorator
  property :next_steps, as: :nextSteps
  property :description, exec_context: :decorator
  property :name, exec_context: :decorator

  property :accounts, decorator: Operative::AccountsRepresenter, exec_context: :decorator
  property :custom_fields, decorator: Operative::CustomFieldsRepresenter, exec_context: :decorator,
           if: -> (options) { options[:enable_operative_extra_fields].eql?(true) || options[:buzzfeed].eql?(true) }

  property :sales_stage_name, as: 'v2:name', wrap: 'v2:salesStage', exec_context: :decorator,
           if: -> (options) { (options[:create].eql?(true) || options[:closed_lost].eql?(false)) }

  property :sales_stage_id, as: 'v2:id', wrap: 'v2:salesStage', exec_context: :decorator,
           if: -> (options) { options[:closed_lost].eql?(true) && options[:enable_operative_extra_fields].eql?(false) }
  property :operative_mashable_stage_id, as: 'v2:id', wrap: 'v2:salesStage', exec_context: :decorator,
           if: -> (options) { options[:enable_operative_extra_fields].eql?(true) && options[:closed_lost].eql?(true) }

  property :primary_sales_person, as: :primarySalesperson, exec_context: :decorator
  property :owner, exec_context: :decorator

  property :xsi_type, attribute: true, exec_context: :decorator, as: 'xsi:type'
  property :xmlns_xsi, attribute: true, exec_context: :decorator, as: 'xmlns:xsi'

  def custom_fields
    represented
  end

  def xsi_type
    'v2:SalesOrderV2'
  end

  def xmlns_xsi
    'http://www.w3.org/2001/XMLSchema-instance'
  end

  def accounts
    represented
  end

  def determine_type
    represented.agency.present? ? 'Agency Buy' : 'Direct to Advertiser'
  end

  def sales_order_type
    deal_type.present? ? deal_type.titleize : determine_type
  end

  def deal_type
    @_deal_type ||= Deal.get_option(represented, 'Deal Type')
  end

  def mashable_sales_order_type
    if order_type_cf.present? && represented.deal_custom_field.present? && account_cf_billable_client_id_value.present?
      account_cf_billable_client_id_value
    end
  end

  def name
    "#{represented.name}_#{represented.id}"
  end

  def alternate_id
    "boostr_#{represented.id}_#{represented.company.name}_order"
  end

  def sales_stage_name
    represented.stage.name
  end

  def sales_stage_id
    7
  end

  def operative_mashable_stage_id
    8
  end

  def description
    "Budget: #{deal_budget}, start date: #{deal_start_date}, end_date: #{deal_end_date}"
  end

  def deal_budget
    number_to_currency(represented.budget, unit: currency_symbol)
  end

  def deal_start_date
    represented.start_date.strftime('%A, %d %b %Y')
  end

  def deal_end_date
    represented.end_date.strftime('%A, %d %b %Y')
  end

  def currency_symbol
    Currency.find_by_curr_cd(represented.creator.default_currency).curr_symbol
  end

  def primary_sales_person
    deal_members_emails[0] || owner_email
  end

  def owner
    owner_email || deal_members_emails[0]
  end

  def deal_members_emails
    represented.deal_members.emails_for_users_except_account_manager_user_type
  end

  def owner_email
    represented.users.find_by(user_type: ACCOUNT_MANAGER).email rescue nil
  end

  def order_type_cf
    @_order_type_cf ||= represented.company.deal_custom_field_names.find_by(field_label: 'Order Type')
  end

  def account_cf_billable_client_id_value
    represented.deal_custom_field.send(order_type_cf.field_name)
  end

  def buzzfeed_order_type
    'Direct Sales'
  end
end
