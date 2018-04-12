class DealsWorkflowQueryBuilder
  attr_reader :query, :workflow_criterions, :deal_id

  def initialize(query = nil, workflow_criterions, deal_id)
    @query = query
    @workflow_criterions = workflow_criterions
    @deal_id = deal_id
  end

  def get_query
    return build_query.project(Arel.star) unless query
    build_query.project(query)
  end

  def build_query
    # relation = deals.join(currencies).on(deals[:curr_cd].eq(currencies[:curr_cd])).where(deals[:id].eq deal_id)
    relation = joins_on.where(deals[:id].eq deal_id)
                   .where(without_deleted)
                   .distinct

    workflow_criterions.to_a.uniq(&:base_object).each do |criterion|
      relation = criterion.join_table(relation)
    end

    return relation unless workflow_criterions.present?


    relation = relation.where(
        values_relation
    )
  end

  def deals
    Arel::Table.new :deals
  end

  def deal_members
    Arel::Table.new(:deal_members)
  end

  def currencies
    Arel::Table.new(:currencies)
  end

  def teams
    Arel::Table.new(:teams)
  end

  def users
    Arel::Table.new(:users)
  end

  def clients
    Arel::Table.new(:clients)
  end

  def options
    Arel::Table.new(:options)
  end

  def initiatives
    Arel::Table.new(:initiatives)
  end

  def values
    Arel::Table.new(:values)
  end

  # INFO: Return Join Relations with On Conditions
  def joins_on
    # join(relations).on(conditions)
    condition = deals
    workflow_criterions.each do |wc|
      case wc.field
        when 'currencies'
          condition = condition.join(currencies)
                          .on(deals[:curr_cd].eq(currencies[:curr_cd]))
        when 'deal_type'
          condition = condition.join(values).on(deals[:id].eq(values[:subject_id]))
                          .join(options).on(values[:option_id].eq(options[:id]))
        when 'deal_initiative'
          condition = condition.join(initiatives).on(deals[:initiative_id].eq(initiatives[:id]))
        when 'teams'
          condition = condition
                          .join(deal_members).on(deals[:id].eq(deal_members[:deal_id]))
                          .join(users).on(users[:id].eq(deal_members[:user_id]))
                          .join(teams).on(users[:team_id].eq(teams[:id]))
        when 'client_segments'
          condition = condition
                          .join(clients).on(deals[:advertiser_id].eq(clients[:id]))
                          .join(options).on(clients[:client_segment_id].eq(options[:id]))
        when 'client_regions'
          condition = condition
                          .join(clients).on(deals[:advertiser_id].eq(clients[:id]))
                          .join(options).on(clients[:client_region_id].eq(options[:id]))
        when 'client_categories'
          condition = condition
                          .join(clients).on(deals[:advertiser_id].eq(clients[:id]))
                          .join(options).on(clients[:client_category_id].eq(options[:id]))
        when 'client_subcategories'
          condition = condition
                          .join(clients).on(deals[:advertiser_id].eq(clients[:id]))
                          .join(options).on(clients[:client_subcategory_id].eq(options[:id]))
      end
    end
    condition
  end

  def without_deleted
    deals[:deleted_at].eq(nil)
  end

  def values_relation
    workflow_criterions.reduce(nil) do |rel, criterion|
      criterion.to_arel_with_object(rel)
    end
  end
end
