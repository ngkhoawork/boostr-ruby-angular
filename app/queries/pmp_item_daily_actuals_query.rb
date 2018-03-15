class PmpItemDailyActualsQuery
  def initialize(options, company)
    @options = options
    @company = company
  end

  def perform
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