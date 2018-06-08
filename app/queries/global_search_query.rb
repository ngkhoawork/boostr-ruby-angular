class GlobalSearchQuery
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def perform
    if options[:typeahead]
      records = filtered_records.where.not(searchable_type: 'Activity')
      records.count < limit.to_i ? filtered_records : records
    else
      filtered_records
    end
  end

  private

  def filtered_records 
    PgSearch.multisearch(options[:query])
           .where(company_id: options[:company_id])
           .reorder(order)
           .page(page)
           .limit(limit)
           .includes(:searchable)
  end

  def page
    options[:page] || 1
  end

  def limit
    options[:limit] || 20
  end

  def order
    if options[:order] == 'rank'
      'rank DESC, "order" ASC, id ASC'
    else
      '"order" ASC, rank DESC, id ASC'
    end
  end
end
