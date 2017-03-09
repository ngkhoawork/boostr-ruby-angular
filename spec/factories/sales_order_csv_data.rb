FactoryGirl.define do
  factory :sales_order_csv_data, class: Hash do
    sales_order_id nil
    sales_order_name nil
    order_currency_id nil
    commission_setting nil
    contract_close_date nil
    exchange_rate_at_close nil
    tax_entity nil
    invoice_system_id nil
    terms_conditions nil
    media_plan_id nil
    media_plan_name nil
    order_status nil
    order_start_date nil
    order_end_date nil
    total_order_value nil
    ecpm nil
    line_items_count nil
    tax_value nil
    billing_terms nil
    external_po_number nil
    alternate_order_id nil
    external_notes nil
    billing_notes nil
    default_rate_card nil
    objective nil
    next_steps nil
    header nil
    billing_account_id nil
    billing_account_name nil
    sales_stage_id nil
    sales_stage_name nil
    sales_stage_percent nil
    gross_order_cost nil
    net_order_cost nil
    owner_id nil
    owner_name nil
    primary_salesperson_id nil
    primary_salesperson_name nil
    primary_salesperson_commission nil
    additional_salesperson_id nil
    additional_salesperson_name nil
    additional_salesperson_commission nil
    order_primary_team_id nil
    order_primary_team_name nil
    advertiser_id nil
    advertiser_name { (build :client).name }
    agency_id nil
    agency_name { (build :client).name }
    sales_order_version nil
    created_by nil
    created_by_id nil
    created_on nil
    last_modified_by nil
    last_modified_by_id nil
    last_modified_on nil
    crm_system_id nil
    crm_system_name nil
    external_opportunity_id nil
    last_synced_on nil
    sales_order_type nil
    sales_order_version_number nil
    billing_period_scheme nil
    end_of_flight nil
    time_zone nil
    # date '01/01/2016'
    # creator nil
    # deal { (build :deal).name }
    # type nil
    # comment { FFaker::HipsterIpsum.phrase }
    # contacts nil

    initialize_with { attributes }

  #   after(:build) do |item|
  #     if item[:creator].nil?
  #       item[:creator] = Company.first.users.first.email
  #     end

  #     if item[:type].nil?
  #       item[:type] = Company.first.activity_types.sample.name
  #     end

  #     if item[:deal].nil?
  #       item[:deal] = Deal.where(name: 'New Big Deal').first.name
  #     end

  #     if item[:contacts].nil?
  #       item[:contacts] = Company.first.contacts.map(&:address).map(&:email).join(';')
  #     end
  #   end
  end
end
