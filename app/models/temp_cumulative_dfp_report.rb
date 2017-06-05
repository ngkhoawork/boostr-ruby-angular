class TempCumulativeDfpReport < ActiveRecord::Base
  scope :duplicating_line_item_ids_by_company, ->(company_id) do
    # duplicating_lines = TempCumulativeDfpReport.group(:dimensionline_item_id).having('count(temp_cumulative_dfp_reports.dimensionline_item_id) > 1').pluck(:dimensionline_item_id)
    # where('company_id = ? and dimensionline_item_id in (?)', company_id, duplicating_lines)
    TempCumulativeDfpReport.group(:dimensionline_item_id).where(company_id: company_id).having('count(temp_cumulative_dfp_reports.dimensionline_item_id) > 1').pluck(:dimensionline_item_id)
  end
end
