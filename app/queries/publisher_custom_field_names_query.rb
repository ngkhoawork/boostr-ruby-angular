class PublisherCustomFieldNamesQuery
  def initialize(relation, options)
    @relation = relation.extending(Scopes)
    @options = options
  end

  def perform
    return relation if relation.empty?

    relation
      .by_field(:field_type, options[:field_type])
      .by_field(:is_required, options[:is_required])
      .by_field(:show_on_modal, options[:show_on_modal])
      .by_field(:disabled, options[:disabled])
      .order_by_position
  end

  private

  attr_reader :relation, :options

  module Scopes
    def by_field(name, value)
      value.nil? ? self : where(name => value)
    end
  end
end
