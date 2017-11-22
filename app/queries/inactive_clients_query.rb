class InactiveClientsQuery
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def perform
    @result ||= clients_relation
  end

  private

  def clients_relation
    Client.where(id: options[:ids])
      .by_category(options[:category_id])
      .by_subcategory(options[:subcategory_id])
      .includes(:users, :latest_advertiser_activity)
      .distinct
  end
end
