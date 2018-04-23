class PmpsQuery < BaseQuery

  def perform
    if options[:without_advertisers]
      filter.without_advertiser
    else
      filter
    end
  end

  def filter
    name_relation
        .union(advertiser_relation)
        .union(agency_relation)
        .includes(:agency, :advertiser, :currency)
        .by_start_date(options[:start_date], options[:end_date])
  end

  private

  def default_relation
    Pmp.all.extending(Scopes).by_company_id(options[:company_id])
  end

  def name_relation
    default_relation.by_name(options[:name])
  end

  def advertiser_relation
    default_relation.by_advertiser_name(options[:name])
  end

  def agency_relation
    default_relation.by_agency_name(options[:name])
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(company_id: company_id)
    end

    def by_name(name)
      name.nil? ? self : where('pmps.name ilike ?', "%#{name}%")
    end

    def by_advertiser_name(name)
      name.nil? ? self : joins(:advertiser).where('clients.name ilike ?', "%#{name}%")
    end

    def by_agency_name(name)
      name.nil? ? self : joins(:agency).where('clients.name ilike ?', "%#{name}%")
    end

    def by_start_date(start_date, end_date)
      start_date.nil? || end_date.nil? ? self : where(start_date: start_date..end_date)
    end
  end
end
