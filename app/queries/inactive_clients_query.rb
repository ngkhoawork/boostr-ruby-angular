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
    default_relation.where(id: options[:ids])
      .by_category(options[:category_id])
      .by_subcategory(options[:subcategory_id])
      .includes(:users, :latest_advertiser_activity)
      .by_member_id(seller_id)
      .by_member_id(team&.all_members_and_leaders_ids)
      .distinct
  end

  def default_relation
    Client.all.extending(Scopes)
  end

  def seller_id
    @_seller_id ||= User.find(options[:seller_id])&.id if options[:seller_id].present?
  end

  def team
    @_team ||= Team.find(options[:team_id]) if options[:team_id].present?
  end

  module Scopes
    def by_member_id(member_id)
      member_id.nil? ? self : where(users: {id: member_id})
    end
  end
end
