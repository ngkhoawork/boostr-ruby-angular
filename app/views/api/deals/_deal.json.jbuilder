json.extract! deal, :id, :name, :budget_loc, :created_at, :curr_cd, :deal_contacts, :updated_at, :next_steps,
                    :stage_id, :previous_stage_id, :stage_updated_at, :closed_at, :advertiser_id, :agency_id,
                    :initiative_id

json.start_date deal.start_date.to_datetime
json.end_date deal.end_date.to_datetime
json.days deal.days
json.months deal.months
json.days_per_month deal.days_per_month
json.currency deal.currency

json.stage deal.stage, :name, :probability, :color, :open
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
  json.deal_product_budgets deal_product.deal_product_budgets.order(:start_date) do |deal_product_budget|
    json.id deal_product_budget.id
    # json.budget (deal_product_budget.budget || 0).to_i
    json.budget_loc (deal_product_budget.budget_loc || 0).to_f
  end
  # json.budget (deal_product.budget || 0).to_i
  json.budget_loc (deal_product.budget_loc || 0).to_f
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
  json.advertiser deal.advertiser, :id, :name
end

if deal.agency
  json.agency deal.agency, :id, :name
end

json.values deal.values
json.fields deal.fields

json.activities deal.activities do |activity|
  json.extract! activity, :id, :happened_at, :comment, :activity_type
  json.creator activity.creator
  json.deal activity.deal
  json.client activity.client
  json.contacts activity.contacts
end

json.initiatives deal.company.initiatives, :id, :name

if deal.initiative.present?
  json.initiative deal.initiative, :id, :name
end
