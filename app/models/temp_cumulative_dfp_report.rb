class TempCumulativeDfpReport < ActiveRecord::Base
  scope :duplicating_line_item_ids_by_company, ->(company_id) do
    group(:dimensionline_item_id).where(company_id: company_id).having('count(temp_cumulative_dfp_reports.dimensionline_item_id) > 1').pluck(:dimensionline_item_id)
  end

  before_save :divide_dfp_numbers

  private

  def divide_dfp_numbers
    self.dimensionattributeline_item_cost_per_unit = dimensionattributeline_item_cost_per_unit / 1_000_000
    self.dimensionattributeline_item_non_cpd_booked_revenue = dimensionattributeline_item_non_cpd_booked_revenue / 1_000_000
    self.columntotal_line_item_level_all_revenue = columntotal_line_item_level_all_revenue / 1_000_000
  end
end
