json.extract! deal, :id, :name, :budget, :created_at, :updated_at, :next_steps, :stage_id, :previous_stage_id, :stage_updated_at, :closed_at, :advertiser_id, :agency_id

json.start_date deal.start_date.to_datetime
json.end_date deal.end_date.to_datetime
json.days deal.days
json.months deal.months
json.days_per_month deal.days_per_month

json.stage deal.stage, :name, :probability, :color, :open
if deal.previous_stage
  json.previous_stage deal.previous_stage, :name, :probability, :color, :open
end

json.creator deal.creator, :first_name, :last_name

json.products deal.products do |product|
  json.id product.id
  json.name product.name
  json.deal_products product.deal_products.where(deal_id: deal).order(:start_date) do |deal_product|
    json.id deal_product.id
    json.budget deal_product.budget / 100
  end
  json.total_budget product.deal_products.where(deal_id: deal).sum(:budget) / 100
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
