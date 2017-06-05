module DFP
  class TempCumulativeReportService < BaseService

    def get_merged_row
      totals.each_with_object({}) do |total, hsh|
        hsh.merge!(base_itm_to_merge)
        hsh[:columntotal_line_item_level_impressions_sum] = total[:impr_sum]
        hsh[:columntotal_line_item_level_clicks_sum] = total[:clicks_sum]
        hsh[:ctr] = total[:ctr]
        hsh[:product_id] = product_id
      end
    end

    def product_id
      if ad_units_product.any?
        ad_units_product.first.id
      end
    end

    def totals
      items_to_merge.group(:dimensionline_item_id).select('sum(columntotal_line_item_level_impressions) as impr_sum,
                             sum(columntotal_line_item_level_clicks) as clicks_sum,
                             (CAST(sum(columntotal_line_item_level_clicks) as FLOAT) / CAST(sum(columntotal_line_item_level_impressions) as FLOAT)) as ctr,
                             dimensionline_item_id')


    end

    def base_itm_to_merge
      items_to_merge.first.attributes.symbolize_keys.except(:id,
                                                            :dimensionad_unit_name,
                                                            :columntotal_line_item_level_impressions,
                                                            :columntotal_line_item_level_clicks,
                                                            :columntotal_line_item_level_ctr,
                                                            :created_at,
                                                            :updated_at)
    end

    def items_to_merge
      @items_to_merge ||= TempCumulativeDfpReport.where(dimensionline_item_id: duplicating_line_item_id)
    end

    def ad_units_product
      ad_units_names = items_to_merge.pluck(:dimensionad_unit_name)
      Product.joins(:ad_units).where('ad_units.name in (?) and products.company_id = ?', ad_units_names, company_id)
    end
  end
end