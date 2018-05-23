class GlobalSearchQuery
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def perform
    PgSearch.multisearch(options[:query])
           .where(company_id: options[:company_id])
           .reorder(order)
           .page(page)
           .limit(limit)
           .includes(:searchable)
  end

  private

  def page
    options[:page] || 1
  end

  def limit
    options[:limit] || 20
  end

  def order
    if options[:order] == 'rank'
      'rank DESC'
    else
      'searchable_type ASC, rank DESC, id ASC'
    end
  end
end
