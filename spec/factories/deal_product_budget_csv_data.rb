FactoryGirl.define do
  factory :deal_product_budget_csv_data, class: Hash do
    deal_id nil
    deal_name nil
    deal_product nil
    budget 10000.0
    period 'July 2015'
    # start_date '2016-01-01 00:00:00 +0200'
    # end_date '2016-02-02 00:00:00 +0200'

    initialize_with { attributes }

    after(:build) do |item|
      if item[:deal_name].nil?
        item[:deal_name] = Company.first.deals.order(:id).first.name
      end

      if item[:deal_product].nil?
        item[:deal_product] = Company.first.products.sample.name
      end

      # if item[:agency].nil?
      #   item[:agency] = Company.first.clients.order(:id).second.name
      # end

      # if item[:stage].nil?
      #   item[:stage] = Company.first.stages.sample.name
      # end

      # if item[:team].nil?
      #   user = Company.first.users.first
      #   item[:team] = user.email + '/100'
      # end
    end
  end
end