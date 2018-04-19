class WorkflowCriterion < ActiveRecord::Base
  belongs_to :workflow, required: true
  belongs_to :workflow_criterion

  validates :base_object, :field, :math_operator, :value, presence: true

  before_save :convert_date, if: :date_field?

  delegate :workflowable_type, to: :workflow

  def convert_date
    self.value = self.value.to_date
  end

  def date_field?
    data_type == 'date' || data_type == 'datetime'
  end

  def options
    Arel::Table.new(:options)
  end

  def currencies
    Arel::Table.new(:currencies)
  end

  def initiatives
    Arel::Table.new(:initiatives)
  end

  def teams
    Arel::Table.new(:teams)
  end

  def account_cfs
    Arel::Table.new(:account_cfs)
  end

  def deal_custom_fields
    Arel::Table.new(:deal_custom_fields)
  end

  def to_arel
    return currencies[:curr_cd].send(arel_operator, criteria_value) if field.eql?("currencies")
    return options[:name].send(arel_operator, criteria_value) if field.eql?("deal_type")
    return initiatives[:name].send(arel_operator, criteria_value) if field.eql?("deal_initiative")
    return teams[:name].send(arel_operator, criteria_value) if field.eql?("teams")
    return options.alias(:client_segments)[:name].send(arel_operator, criteria_value) if field.eql?("client_segments")
    return options.alias(:client_regions)[:name].send(arel_operator, criteria_value) if field.eql?("client_regions")
    return options.alias(:client_categories)[:name].send(arel_operator, criteria_value) if field.eql?("client_categories")
    return options.alias(:client_subcategories)[:name].send(arel_operator, criteria_value) if field.eql?("client_subcategories")
    return account_cfs[field].send(arel_operator, criteria_value) if base_object.eql?('Account Custom Fields')
    return deal_custom_fields[field].send(arel_operator, criteria_value) if base_object.eql?('Deal Custom Fields')
    criteria_field.send(arel_operator, date_field? ? criteria_value.to_time.utc : criteria_value)
  end

  def ilike_string
    case math_operator
      when 'contains'
        "%#{self.value}%"
      when 'ends_with'
        "%#{self.value}"
      when 'starts_with'
        "#{self.value}%"
      else
        nil
    end
  end

  def criteria_value
    ilike_string || self.value
  end

  def criteria_field
    if self.value.is_date?
      Arel::Nodes::NamedFunction.new('CAST', [ ar_table[self.field.to_sym].as('DATE') ])
    else
      ar_table[self.field.to_sym]
    end
  end

  def to_arel_with_object(obj)
    obj&.send(relation_operator, to_arel) || to_arel
  end

  def join_table(relation)
    return relation if should_not_join?

    join_reflection(relation, reflection)
  end

  def join_reflection(relation, refl)
    chain = refl.chain.reverse
    chain.each_with_index do |assoc, index|
      join_table = ar_table assoc
      join_table_name = join_table.name

      next if sql_contains_joined_table?(relation, join_table_name) && !is_aliased?(assoc)

      if index == 0
        predicate_table = parent_table
        join_keys = assoc.join_keys(join_table)
      else
        predicate_table = ar_table chain[index - 1]
        join_keys = assoc.join_keys(predicate_table)
      end

      relation = relation.join(join_table, Arel::Nodes::OuterJoin).on(
          join_table[join_keys.key].eq(predicate_table[join_keys.foreign_key])
      )
    end

    relation
  end

  def sql_contains_joined_table?(relation, table_name)
    return if relation.kind_of? Arel::Table
    sql_string = relation.to_sql
    sql_string.scan(/JOIN "#{table_name}"/).any?
  end

  def ar_table(refl=nil)
    refl ||= reflection
    table_name = refl.table_name.to_sym

    if is_aliased?(refl)
      Arel::Table.new(table_name).alias(refl.name.to_s)
    else
      Arel::Table.new(table_name)
    end
  end

  private

  def should_not_join?
    !reflection.present? ||
        (reflection == parent_object)
  end

  def is_aliased?(reflection)
    parent_object.reflections[reflection.name.to_s].present? && reflection.name.to_s.snakecase.pluralize != reflection.table_name
  end

  def parent_object
    workflowable_type.constantize
  end

  def parent_table
    Arel::Table.new workflowable_type.pluralize.snakecase.to_sym
  end

  def base_object_table
    (reflection&.table_name || 'deals').pluralize.snakecase
  end

  def reflection
    @_reflection ||= parent_object.reflections[base_object.downcase] || parent_object
  end

  def arel_operator
    case math_operator
      when 'contains'
        :matches
      when 'starts_with'
        :matches
      when 'ends_with'
        :matches
      when '>'
        :gt
      when '<'
        :lt
      when '>='
        :gteq
      when '<='
        :lteq
      when '!='
        :not_eq
      when '='
        :eq
      else
        :eq
    end
  end

  def relation_operator
    case relation
      when 'OR'
        :or
      else
        :and
    end
  end
end
