module Helpers
  def ui_select(name, value)
    container = find(".ui-select-container[name='#{name}']")
    within container do
      within '.ui-select-match' do
        find('span.btn').click
      end
      find('.ui-select-search').set(value)
      find('.ui-select-choices-row-inner').click
    end
  end

  def csv_file(rows)
    "Order #,Line #,AdServer,Qty,Price,Price Type,Delivered Qty,Remaining Qty,Budget,Budget Remaining,Start Date,End Date,Advertiser,Advertiser ID,Sales Rep, Product ID\n#{rows}"
  end

  def good_csv_file(client, user, product)
    csv_file("1234,8,Taco,100000,7,CPE,50000,50000,700000,350000,9/7/2015,1/6/2016,Converse,#{client.id},#{user.email},#{product.id}")
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
end
