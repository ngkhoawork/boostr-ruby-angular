class PmpItemMonthlyActual < ActiveRecord::Base
  belongs_to :pmp_item, required: true

  validates :amount, :amount_loc, presence: true

  def self.generate(pmp_item_ids)
    PmpItemMonthlyActual.transaction do
      PmpItemMonthlyActual.where(pmp_item_id: pmp_item_ids).destroy_all
      pmp_item_monthly_actuals = PmpItemDailyActual.select('pmp_item_id, sum(revenue) as amount, sum(revenue_loc) as amount_loc, min(date) as start_date, max(date) as end_date')
        .where(pmp_item_id: pmp_item_ids)
        .group("pmp_item_id, to_char(date, 'YYYY-MM')").as_json
      PmpItemMonthlyActual.create(pmp_item_monthly_actuals)
    end
  end
end