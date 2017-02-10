class Operative::Deals::Single < API::Single
  include Representable::JSON
  include ActionView::Helpers::NumberHelper

  property :name, exec_context: :decorator
  property :alternate_id, as: :alternateId, exec_context: :decorator
  property :accounts, exec_context: :decorator
  property :next_steps, as: :nextSteps
  property :description, exec_context: :decorator

  nested :salesOrderType, exec_context: :decorator do
    property :type, as: :name
  end

  property :stage, as: :salesStage do
    property :name
  end

  property :primary_sales_person, as: :primarySalesperson, exec_context: :decorator
  property :owner, exec_context: :decorator

  def name
    "#{represented.name}_#{represented.id}"
  end

  def type
    represented.agency.present? ? 'Agency Buy' : 'Direct to Advertiser'
  end

  def alternate_id
    represented.id
  end

  def description
    "Budget: #{deal_budget}, start date: #{deal_start_date}, end_date: #{deal_end_date}"
  end

  def accounts
    [advertiser_account, agency_account].compact
  end

  def advertiser_account
    { 'account' => { 'externalId' => advertiser_external_id.to_s } } if advertiser_external_id.present?
  end

  def agency_account
    { 'account' => { 'externalId' => agency_external_id.to_s } } if agency_external_id.present?
  end

  def advertiser_external_id
    @_advertiser_external_id ||= represented.advertiser_id
  end

  def agency_external_id
    @_agency_external_id ||= represented.agency_id
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
    deal_members_emails.last
  end

  def owner
    deal_members_emails.first
  end

  def deal_members_emails
    @_deal_members_emails ||= represented.deal_members.ordered_by_share.map(&:email)
  end
end
