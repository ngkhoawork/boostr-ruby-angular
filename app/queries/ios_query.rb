class IosQuery < BaseQuery
  def perform
    default_relation
      .by_name_or_advertiser_name_or_agency_name(options[:name])
      .by_start_date_range(options[:start_date_start], options[:start_date_end])
      .by_end_date_range(options[:end_date_start], options[:end_date_end])
      .by_advertiser_id(options[:advertiser_id])
      .by_agency_id(options[:agency_id])
      .by_budget_range(options[:budget_start], options[:budget_end])
      .by_io_number(options[:io_number])
      .by_external_io_number(options[:external_io_number])
  end

  private

  def default_relation
    (options[:default_relation] || Io.all).extending(Scopes)
  end

  module Scopes
    def by_start_date_range(start_date_start, start_date_end)
      by_start_date(start_date_start, start_date_end)
    end

    def by_end_date_range(end_date_start, end_date_end)
      (end_date_start && end_date_end) ? where(end_date: end_date_start..end_date_end) : self
    end

    def by_budget_range(budget_start, budget_end)
      (budget_start && budget_end) ? where(budget: budget_start..budget_end) : self
    end

    def by_io_number(io_number)
      io_number ? where(io_number: io_number) : self
    end

    def by_external_io_number(external_io_number)
      external_io_number ? where(external_io_number: external_io_number) : self
    end

    def by_name_or_advertiser_name_or_agency_name(name)
      return self unless name

      joins('JOIN clients advertisers ON advertisers.id = ios.advertiser_id AND advertisers.deleted_at IS NULL')
        .joins('JOIN clients agencies ON agencies.id = ios.agency_id AND agencies.deleted_at IS NULL')
        .where('ios.name ilike :name OR advertisers.name ilike :name OR agencies.name ilike :name', name: "%#{name}%")
    end
  end
end
