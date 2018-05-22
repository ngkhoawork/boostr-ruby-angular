class PmpItemDailyActualsQuery
  def initialize(options, company)
    @options = options
    @company = company
  end

  def perform
    return grouped_item_records if options['list_type'].eql?('grouped') && options['custom'].eql?('items')
    return grouped_records if options['list_type'].eql?('grouped') && !options['custom'].eql?('items')
    relation.by_start_date(options[:start_date], options[:end_date])
        .with_advertiser(options[:with_advertiser])
        .order(:pmp_item_id, :date)
        .includes({
          pmp_item: {
            product: {}, 
            ssp: {},
            pmp: :currency
          },
          advertiser: {}
        })
  end

  private

  attr_reader :relation, :options, :company

  def grouped_records
    results = company
                  .pmp_items.where(without_adv: true)
    if options[:name].present?
      results = results
                    .includes(:pmp_item_daily_actuals,:pmp)
                    .extending(Scopes)
                    .where(pmp_item_daily_actuals: {advertiser_id: nil})
                    .where.not(pmp_item_daily_actuals: {revenue: 0.0})
                    .by_start_date(options[:start_date], options[:end_date])
                    .where('pmp_item_daily_actuals.ssp_advertiser ilike ? OR pmps.name ilike ? OR ssp_deal_id ilike ?',
                           "%#{options[:name]}%", "%#{options[:name]}%", "%#{options[:name]}%")
    end
    if options[:agency_id].present?
      results = results.where(agency_id: options[:agency_id])
    end
    results.order(total_revenue_by_daily_items: :desc)
  end

  def grouped_item_records
    company
        .pmp_item_daily_actuals
        .where(pmp_item_id: options[:pmp_item_id])
        .where(pmp_item_daily_actuals: {advertiser_id: nil})
        .where.not(revenue: 0.0)
  end

  def relation
    if options[:name].nil?
      default_relation
    else
      name_relation
        .union(advertiser_relation)
        .extending(Scopes)
    end
  end

  def default_relation
    PmpItemDailyActual.all.extending(Scopes)
      .joins(pmp_item: :pmp)
      .by_company_id(company.id)
      .by_pmp_id(options[:pmp_id])
      .by_pmp_item_id(options[:pmp_item_id])
      .distinct
  end

  def name_relation
    default_relation
      .by_name(options[:name])
  end

  def advertiser_relation
    default_relation
      .by_pmp_name(options[:name])
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(pmps: {company_id: company_id})
    end

    def by_pmp_id(pmp_id)
      pmp_id.nil? ? self : where(pmps: {id: pmp_id})
    end

    def by_pmp_item_id(pmp_item_id)
      return self unless pmp_item_id
      where('pmp_item_id = ?', pmp_item_id)
    end

    def by_name(name)
      name.nil? ? self : where('ssp_advertiser ilike ?', "%#{name}%")
    end

    def by_start_date(start_date, end_date)
      start_date.nil? || end_date.nil? ? self : where(date: start_date..end_date)
    end

    def by_pmp_name(name)
      name.nil? ? self : where('pmps.name ilike ?', "%#{name}%")
    end

    def with_advertiser(bool)
      return self if bool.nil?
      if bool.to_s == 'true'
        where('pmp_item_daily_actuals.advertiser_id IS NOT NULL')
      else
        where('pmp_item_daily_actuals.advertiser_id IS NULL')
      end
    end
  end
end