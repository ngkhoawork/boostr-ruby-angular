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

  def client_segments
    options.alias(:client_segments)
  end

  def client_regions
    options.alias(:client_regions)
  end

  def client_categories
    options.alias(:client_categories)
  end

  def client_subcategories
    options.alias(:client_subcategories)
  end

  def account_cfs
    Arel::Table.new(:account_cfs)
  end

  def deal_custom_fields
    Arel::Table.new(:deal_custom_fields)
  end

  def fields
    Arel::Table.new(:fields)
  end

  def members
    Arel::Table.new(:members)
  end

  def member_roles
    options.alias(:member_roles)
  end

  # INFO: Return Join Relations with On Conditions
  def joins_on
    # join(relations).on(conditions)
    condition = deals.join(clients)
                    .on(deals[:advertiser_id].eq(clients[:id]))
      workflow_criterions.each do |wc|
        case wc.field
          when 'currencies'
            condition = condition
                            .join(currencies)
                            .on(deals[:curr_cd].eq(currencies[:curr_cd]))
          when 'deal_type'
            condition = condition
                            .join(values)
                            .on(deals[:id].eq(values[:subject_id]))
                            .join(options)
                            .on(values[:option_id].eq(options[:id]))
          when 'deal_initiative'
            condition = condition
                            .join(initiatives)
                            .on(deals[:initiative_id].eq(initiatives[:id]))
          when 'teams'
            condition = condition
                            .join(deal_members)
                            .on(deal_members[:deal_id].eq(deals[:id]))
                            .join(users)
                            .on(users[:id].eq(deal_members[:user_id]))
                            .join(teams)
                            .on(teams[:id].eq(users[:team_id]).or(teams[:leader_id].eq(users[:id])))
          when 'client_segments'
            condition = condition
                            .join(client_segments)
                            .on(clients[:client_segment_id].eq(client_segments[:id]))
          when 'client_regions'
            condition = condition
                            .join(client_regions)
                            .on(clients[:client_region_id].eq(client_regions[:id]))
          when 'client_categories'
            condition = condition
                            .join(client_categories)
                            .on(clients[:client_category_id].eq(client_categories[:id]))
          when 'client_subcategories'
            condition = condition
                            .join(client_subcategories)
                            .on(clients[:client_subcategory_id].eq(client_subcategories[:id]))
          when 'share'
            condition = condition
                            .join(deal_members)
                            .on(deal_members[:deal_id].eq(deals[:id]))
        end
        case wc.base_object
          when 'Account Custom Fields'
            unless condition.to_sql.include?("INNER JOIN \"account_cfs\"")
            condition = condition
                            .join(account_cfs)
                            .on(clients[:id].eq(account_cfs[:client_id]))
            end
          when 'Deal Custom Fields'
            unless condition.to_sql.include?("INNER JOIN \"deal_custom_fields\"")
            condition = condition
                            .join(deal_custom_fields)
                            .on(deals[:id].eq(deal_custom_fields[:deal_id]))
            end
          when 'Deal Members'
            condition = condition
                            .join(deal_members)
                            .on(deal_members[:deal_id].eq(deals[:id]))
                            .join(values)
                            .on(values[:subject_id].eq(deal_members[:id]))
                            .join(fields)
                            .on(values[:field_id].eq(fields[:id]))
                            .join(member_roles)
                            .on(fields[:id].eq(member_roles[:field_id])) if wc.field.eql?('role')
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
