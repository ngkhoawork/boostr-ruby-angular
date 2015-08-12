json.extract! deal, :start_date, :end_date, :name, :budget, :created_at, :updated_at, :deal_type, :source_type, :next_steps
json.stage deal.stage, :name, :probability, :color
json.creator deal.creator, :first_name, :last_name
json.days deal.days
json.months deal.months
json.days_per_month deal.days_per_month
json.products deal.products do |product|
  json.id product.id
  json.name product.name
  json.deal_products product.deal_products.where(deal_id: deal) do |deal_product|
    json.id deal_product.id
    json.budget deal_product.budget
  end
end
