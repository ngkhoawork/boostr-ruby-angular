class PmpItemDailyActualsQuery
  def initialize(options, company)
    @options = options
    @company = company
    @relation = default_relation.extending(Scopes)
  end

  def perform
    return relation if options.blank?
    relation
        .by_name(options[:name])
        .by_start_date(options[:start_date], options[:end_date])
        .by_pmp_item_id(options[:pmp_item_id])
        .with_advertiser(options[:with_advertiser])
        .order(:pmp_item_id, :date)
        .distinct
  end

  private

  attr_reader :relation, :options, :pmp, :company

  def default_relation
    if options[:pmp_id]
      pmp.pmp_item_daily_actuals
    else
      company.pmp_item_daily_actuals
    end
  end

  def pmp
    @_pmp ||= Pmp.find(options[:pmp_id])
  end

  module Scopes
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