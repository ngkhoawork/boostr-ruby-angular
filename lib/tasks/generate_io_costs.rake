namespace :generate_io_costs do
  desc "TODO"
  task :process_task, [:company_id] => [:environment] do |t, args|
    if args[:company_id]
      company = Company.find(args[:company_id])
      if company.present?
        deals = company.deals
          .at_percent(100)
          .has_io
        deals.each do |deal|
          deal.deal_products.each do |deal_product|
            create_io_cost(company, deal, deal_product)
          end
        end
      end
    end
  end

  def create_io_cost(company, deal, deal_product)
    io = deal.io
    product = deal_product.product
    cost = io.costs.find_by(product_id: product.id)
    if cost.nil? && product.margin && product.margin < 100 && product.margin > 0
      cost = io.costs.create({
        product_id: product.id,
        budget: deal_product.budget * (100 - product.margin) / 100,
        budget_loc: deal_product.budget_loc * (100 - product.margin) / 100,
        is_estimated: true,
        values_attributes: [cost_values_param(company)]
      })
      puts "=========="
      puts cost.id
      puts deal.id
    end
  end

  def cost_values_param(company)
    return @_cost_values_param if defined?(@_cost_values_param)
    cost_type_field = company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
    cost_type = cost_type_field.option_from_name('General')
    @_cost_values_param = {
      value_type: 'Option',
      subject_type: 'Cost',
      field_id: cost_type_field.id,
      option_id: cost_type.id,
      company_id: company.id
    }
  end
end
