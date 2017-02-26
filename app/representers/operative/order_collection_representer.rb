require 'representable/xml'

class Operative::OrderCollectionRepresenter < Representable::Decorator
  include Representable::XML
  include ActionView::Helpers::NumberHelper

  self.representation_wrap = :salesOrder

  property :sales_order_type, as: :name, exec_context: :decorator, wrap: :salesOrderType
  property :alternate_id, as: :alternateId, exec_context: :decorator
  property :next_steps, as: :nextSteps
  property :description, exec_context: :decorator
  property :name, exec_context: :decorator

  property :accounts, decorator: Operative::AccountsRepresenter, exec_context: :decorator
  property :sales_stage, as: 'v2:name', wrap: 'v2:salesStage', exec_context: :decorator, if: -> (options) { options[:create].eql? true }
  property :primary_sales_person, as: :primarySalesperson, exec_context: :decorator
  property :owner, exec_context: :decorator

  property :xsi_type, attribute: true, exec_context: :decorator, as: 'xsi:type'
  property :xmlns_xsi, attribute: true, exec_context: :decorator, as: 'xmlns:xsi'

  def xsi_type
    'v2:SalesOrderV2'
  end

  def xmlns_xsi
    'http://www.w3.org/2001/XMLSchema-instance'
  end

  def accounts
    represented
  end

  def sales_order_type
    represented.agency.present? ? 'Agency Buy' : 'Direct to Advertiser'
  end

  def name
    "#{represented.name}_#{represented.id}"
  end

  def alternate_id
    "boostr_#{represented.id}_#{represented.company.name}_order"
  end

  def sales_stage
    map_stage_name
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
    owner_email
  end

  def deal_members_emails
    represented.deal_members.emails_for_users_except_account_manager_user_type
  end

  def owner_email
    represented.users.find_by(user_type: ACCOUNT_MANAGER).email
  end

  def map_stage_name
    operative_stages.find { |name| name.include? stage_probability }
  end

  def stage_probability
    represented.stage.probability.to_s
  end

  def operative_stages
    [
      '0% - Closed/Lost',
      '10% - Sales lead',
      '20% - Discuss Requirements',
      '50% - Proposal',
      '60% - Negotiation',
      '80% - Best Case',
      '100% - Closing'
    ]
  end
end
