json.extract! deal, :id, :name, :budget, :budget_loc, :created_at, :curr_cd, :deal_contacts, :updated_at, :next_steps,
                    :stage_id, :previous_stage_id, :stage_updated_at, :closed_at, :advertiser_id, :agency_id,
                    :initiative_id, :next_steps_due

json.start_date deal.start_date.to_datetime
json.end_date deal.end_date.to_datetime
json.days deal.days
json.months deal.months
json.days_per_month deal.days_per_month
json.currency deal.currency
json.company_ealert_reminder deal.company.ealert_reminder
json.requests_enabled deal.company.requests_enabled

json.stage deal.stage, :name, :probability, :color, :open, :active
if deal.previous_stage
  json.previous_stage deal.previous_stage, :name, :probability, :color, :open
end

json.creator deal.creator, :first_name, :last_name

json.deal_contacts(deal.deal_contacts.order(:created_at)) do |deal_contact|
  json.id deal_contact.id
  json.contact_id deal_contact.contact_id
  json.deal_id deal_contact.deal_id
  json.role deal_contact.role
  json.contact deal_contact.contact, :id, :name, :position, :client_id, :note, :formatted_name, :primary_client_json, :address
end


json.products deal.products

if deal.deal_custom_field
  json.deal_custom_field deal.deal_custom_field
end

json.deal_products deal.deal_products.order(:created_at) do |deal_product|
  json.id deal_product.id
  json.name deal_product.product.name
  json.ssp deal_product.ssp
  json.ssp_id deal_product.ssp_id
  json.is_guaranteed deal_product.is_guaranteed
  json.ssp_deal_id deal_product.ssp_deal_id
  json.deal_product_budgets deal_product.deal_product_budgets.order(:start_date) do |deal_product_budget|
    json.id deal_product_budget.id
    json.budget (deal_product_budget.budget || 0).to_i
    json.budget_loc (deal_product_budget.budget_loc || 0).to_f
  end
  json.budget (deal_product.budget || 0).to_i
  json.budget_loc (deal_product.budget_loc || 0).to_f
  json.deal_product_cf deal_product.deal_product_cf
end

json.members deal.deal_members do |member|
  json.extract! member, :id, :share
  json.user_id member.user_id
  json.name member.name
  json.values member.values do |value|
    json.extract! value, :id, :option_id, :field_id
    json.option value.option
    json.value value.value
  end
end

if deal.advertiser
  json.advertiser do
    json.extract! deal.advertiser, :id, :name

    json.stats do
      json.deals_count deal.advertiser.advertiser_deals_count
      json.win_rate deal.advertiser.advertiser_win_rate
      json.avg_deal_size deal.advertiser.advertiser_avg_deal_size
      json.last_deal deal.advertiser.last_advertiser_deal(deal)
    end
  end
end

if deal.has_billing_contact?
  json.billing_contact do
    json.extract! deal.billing_contact, :id, :name, :email
  end
end

if deal.agency
  json.agency do
    json.extract! deal.agency, :id, :name

    json.stats do
      json.deals_count deal.agency.agency_deals_count
      json.win_rate deal.agency.agency_win_rate
      json.avg_deal_size deal.agency.agency_avg_deal_size
      json.last_deal deal.agency.last_agency_deal(deal)
    end
  end
end

if !deal.stage.open && deal.stage.probability == 100 && deal.io.present?
  json.io do
    json.extract! deal.io, :id, :name, :budget, :budget_loc, :start_date, :end_date, :readable_months

    json.content_fees deal.io.content_fees do |content_fee|
      json.extract! content_fee, :id, :io_id, :budget, :budget_loc, :content_fee_product_budgets
      json.product content_fee.product
      json.request content_fee.request
    end

    json.display_line_items deal.io.display_line_items do |display_line_item|
      json.extract! display_line_item,
        :id, :io_id, :line_number, :ad_server, :quantity, :budget, :pricing_type,
        :product_id, :budget_delivered, :budget_remaining, :quantity_delivered,
        :quantity_remaining, :start_date, :end_date, :daily_run_rate, :num_days_til_out_of_budget,
        :quantity_delivered_3p, :quantity_remaining_3p, :budget_delivered_3p, :budget_remaining_3p,
        :price, :balance, :last_alert_at, :temp_io_id, :ad_server_product, :budget_loc,
        :budget_delivered_loc, :budget_remaining_loc, :budget_delivered_3p_loc,
        :budget_remaining_3p_loc, :balance_loc, :daily_run_rate_loc
      json.product display_line_item.product
      json.request display_line_item.request
    end
  end
end

if !deal.stage.open && deal.stage.probability == 100 && deal.pmp.present?
  json.pmp do
    json.extract! deal.pmp, :id, :name, :budget, :budget_delivered, :budget_remaining, :budget_loc, :budget_delivered_loc, :budget_remaining_loc, :start_date, :end_date, :curr_cd
    if deal.pmp.currency.present? 
      json.currency_symbol deal.pmp.currency.curr_symbol
    end
    if deal.pmp.agency.present?
      json.agency deal.pmp.agency, :id, :name
    end
    if deal.pmp.advertiser.present?
      json.advertiser deal.pmp.advertiser, :id, :name
    end
    json.pmp_items deal.pmp.pmp_items do |pmp_item|
      json.extract! pmp_item, :ssp_deal_id, :budget, :budget_delivered, :budget_remaining_loc, :budget_loc, :budget_delivered_loc, :budget_remaining_loc 
      json.ssp pmp_item.ssp
    end
  end
end

json.values deal.values
json.fields deal.fields

json.initiatives deal.company.initiatives, :id, :name

if deal.initiative.present?
  json.initiative deal.initiative, :id, :name
end

json.closed_reason_text deal.closed_reason_text
json.curr_symbol deal.currency.curr_symbol

json.operative_order_id deal.integrations.find_by_external_type('operative').try :external_id
