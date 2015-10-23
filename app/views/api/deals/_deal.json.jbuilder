json.extract! deal, :id, :name, :budget, :created_at, :updated_at, :next_steps, :stage_id

json.start_date deal.start_date.to_datetime
json.end_date deal.end_date.to_datetime
json.days deal.days
json.months deal.months
json.days_per_month deal.days_per_month

json.stage deal.stage, :name, :probability, :color

json.creator deal.creator, :first_name, :last_name

json.products deal.products do |product|
  json.id product.id
  json.name product.name
  json.deal_products product.deal_products.where(deal_id: deal).order(:start_date) do |deal_product|
    json.id deal_product.id
    json.budget deal_product.budget / 100
  end
  json.total_budget product.deal_products.where(deal_id: deal).sum(:budget)
end

json.members deal.deal_members do |member|
  json.extract! member, :id, :role, :share
  json.user_id member.user_id
  json.name member.name
end

json.advertiser deal.advertiser, :name

json.values deal.values
json.fields deal.fields
