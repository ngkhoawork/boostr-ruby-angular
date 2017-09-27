class FactTables::AccountProductRevenueFacts::RevenueByRelatedAdvertisersQuery
  def initialize(options = {}, relation = AdvertiserAgencyRevenueFact.joins(:time_dimension, :advertiser))
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def perform
    return relation unless options.any?
    relation.by_time_dimension_date_range(options[:start_date], options[:end_date])
            .by_agencies(options[:agencies_ids])
            .by_related_advertisers(options[:advertisers_ids])
            .by_company_id(options[:company_id])
  end

  private

  attr_reader :relation, :options

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date
             AND time_dimensions.days_length <= 31',
            start_date: start_date,
            end_date: end_date)
    end

    def by_agencies(agencies_ids)
      where('advertiser_agency_revenue_facts.agency_id in (:agencies_ids)
             AND advertiser_agency_revenue_facts.agency_id IS NOT NULL',
            agencies_ids: agencies_ids)
    end

    def by_related_advertisers(advertisers_ids)
      where('advertiser_agency_revenue_facts.advertiser_id in (:advertisers_ids)',
            advertisers_ids: advertisers_ids)
    end

    def by_company_id(id)
      where('advertiser_agency_revenue_facts.company_id = :id', id: id)
    end
  end
end