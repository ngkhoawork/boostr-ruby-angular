class PublisherCustomFieldNamesQuery
  def initialize(relation, options)
    @relation = relation.extending(Scopes)
    @options = options
  end

  def perform
    return relation if options.empty? || options.blank?

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
      value ? where(name => value) : self
    end
  end
end
