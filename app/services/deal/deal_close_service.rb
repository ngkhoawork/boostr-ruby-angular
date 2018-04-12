class Deal::DealCloseService
  def initialize(deal)
    @deal = deal
  end

  def perform
    update_close
  end

  attr_reader :deal

  private

  def update_close
    stage = deal.stage
    if deal.closed_at.nil? && !stage.open?
      deal.closed_at = updated_at
    end

    if !stage.open? && stage.probability == 100
      deal.deal_products.each do |deal_product|
        if deal_product.product.revenue_type != 'Content-Fee'
          deal_product.update_columns(open: true)
        else
          deal_product.update_columns(open: false)
        end
      end
      deal.send_closed_won_deal_notification
    else
      deal.deal_products.update_all(open: stage.open)

      if !deal.closed_at.nil? && stage.open?
        if !deal.fields.nil? && !deal.values.nil?
          field = deal.fields.find_by_name('Close Reason')
          close_reason = deal.values.find_by_field_id(field.id) if !field.nil?
          if !close_reason.nil?
            close_reason.destroy 
            deal.closed_reason_text = nil
          end
        end
      end

      deal.send_stage_changed_deal_notification if stage.open?
    end
  end
end
