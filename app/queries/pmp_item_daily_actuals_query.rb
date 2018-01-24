
class PmpItemDailyActualsQuery
  def initialize(options)
    @options = options
    @relation = default_relation.extending(Scopes)
  end

  def perform
    return relation if options.blank?
    relation
        .by_pmp_item_id(options[:pmp_item_id])
        .order(:pmp_item_id, :date)
  end

  private

  attr_reader :relation, :options, :pmp

  def default_relation
    @_default_relation ||= pmp.pmp_item_daily_actuals
  end

  def pmp
    @_pmp ||= Pmp.find(options[:pmp_id])
  end

  module Scopes
    def by_pmp_item_id(pmp_item_id)
      return self unless pmp_item_id
      where('pmp_item_id = ?', pmp_item_id)
    end
  end
end