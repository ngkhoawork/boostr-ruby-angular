module Helpers
  def ui_select(name, value)
    container = find(".ui-select-container[name='#{name}']")
    within container do
      within '.ui-select-match' do
        find('span.btn').trigger('click')
      end
      find('.ui-select-search').set(value)
      find('.ui-select-choices-row-inner').trigger('click')
    end
  end

  def csv_file(rows)
    "Order #,Line #,AdServer,Qty,Price,Price Type,Delivered Qty,Remaining Qty,Budget,Budget Remaining,Start Date,End Date,Advertiser,Advertiser ID,Sales Rep, Product ID\n#{rows}"
  end

  def good_csv_file(client, user, product)
    csv_file("1234,8,Taco,100000,\"$7.00\",CPE,50000,50000,700000,350000,9/7/2015,1/6/2016,Converse,#{client.id},#{user.email},#{product.id}")
  end

  def missing_required_csv(client, user, product)
    csv_file(",,,100000,7,CPE,50000,50000,700000,350000,9/7/2015,1/6/2016,Converse,#{client.id},#{user.email},#{product.id}")
  end

  def missing_user_csv(client, product)
    csv_file("1234,8,Taco,100000,7,CPE,50000,50000,700000,350000,9/7/2015,1/6/2016,Converse,#{client.id},does@notexist.com,#{product.id}")
  end

  def missing_client_csv(user, product)
    csv_file("1234,8,Taco,100000,7,CPE,50000,50000,700000,350000,9/7/2015,1/6/2016,Converse,0,#{user.email},100000,#{product.id}")
  end

  def missing_product_csv(client, user)
    csv_file("1234,8,Taco,100000,7,CPE,50000,50000,700000,350000,9/7/2015,1/6/2016,Converse,#{client.id},#{user.email},")
  end

  def missing_date_csv(client, user, product)
    csv_file("1234,8,Taco,100000,\"$7.00\",CPE,50000,50000,700000,350000,,1/6/2016,Converse,#{client.id},#{user.email},#{product.id}")
  end

  def set_client_type(client, company, option_name)
    field = client_type_field(company)
    option = field.options.where(name: option_name).first
    create :value, company: company, field: field, subject: client, option: option
  end

  def client_type_field(company)
    company.fields.where(name: 'Client Type').first
  end

  def agency_type_id(company)
    client_type_field(company).options.where(name: "Agency").first.id
  end

  def advertiser_type_id(company)
    client_type_field(company).options.where(name: "Advertiser").first.id
  end

  def deal_type_field(company)
    company.fields.where(name: 'Deal Type').first
  end

  def deal_source_field(company)
    company.fields.where(name: 'Deal Source').first
  end

  def product_pricing_field(company)
    company.fields.where(name: 'Pricing Type').first
  end

  def product_line_field(company)
    company.fields.where(name: 'Product Line').first
  end

  def product_family_field(company)
    company.fields.where(name: 'Product Family').first
  end

  def client_role_field(company)
    company.fields.where(name: 'Member Role').first
  end

  def create_member_role(company, name="Owner")
    client_owner_role_option = create :option, company: company, field: client_role_field(company), name: name
    build :value, company: company, field: client_role_field(company), option: client_owner_role_option
  end
end
