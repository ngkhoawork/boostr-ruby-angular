admin_user = User.create!(
  first_name: "Admin",
  last_name: "User",
  email: "admin@example.com",
  password: "password"
)

company_user = User.create!(
  first_name: "Company",
  last_name: "User",
  email: "company@example.com",
  password: "password"
)

company = Company.create!(
  name: "Acme Corporation",
  billing_address_attributes: {
    street1: '15 Beverly',
    city: 'Los Angeles',
    state: 'CA',
    zip: '90210',
    email: 'hello@example.com',
    website: 'http://example.com',
    phone: '310-555-1212',
    mobile: '310-555-1212'
  },
  physical_address_attributes: {
    street1: '15 Beverly',
    city: 'Los Angeles',
    state: 'CA',
    zip: '90210',
    email: 'hello@example.com',
    website: 'http://example.com',
    phone: '310-555-1212',
    mobile: '310-555-1212'
  },
  primary_contact_id: company_user.id,
  billing_contact_id: company_user.id
)

company_user.company = company
company_user.save

products = company.products.create!([
  { name: "Video", product_line: "Phone", family: "Native", pricing_type: "CPM" },
  { name: "Native Ad - Mobile", product_line: "Tablet", family: "Banner",  pricing_type: "CPC" },
  { name: "Native Ad - Desktop", product_line: "Desktop", family: "Native", pricing_type: "CPC" }
])

stages = company.stages.create!([{
  name: "Prospecting",
  probability: 8,
  open: true,
  active: true,
  position: 1,
  color: "#000000",
},{
  name: "Needs Proposal",
  probability: 20,
  open: true,
  active: true,
  position: 2,
  color: "#000000",
},{
  name: "Proposal",
  probability: 50,
  open: true,
  active: true,
  position: 3,
  color: "#000000",
},{
  name: "Negotiations",
  probability: 0,
  open: true,
  active: true,
  position: 4,
  color: "#000000",
},{
  name: "Verbal Commit",
  probability: 90,
  open: true,
  active: true,
  position: 5,
  color: "#000000",
},{
  name: "Closed Won",
  probability: 100,
  open: nil,
  active: nil,
  position: 6,
  color: "#000000",
},{
  name: "Closed Lost",
  probability: 0,
  open: false,
  active: nil,
  position: 7,
  color: "#000000",
}])

# Teams
team_leader_users = company.users.create!([
  {
    first_name: "Leader",
    last_name: "User",
    email: "leader@example.com",
    password: "password"
  }
])

sales_team = company.teams.create!({
  name: "Sales",
  leader: company_user,
  parent: nil,
})

west_coast_sales_team = company.teams.create!({
  name: "West Coast Sales",
  leader: team_leader_users[0],
  parent: sales_team,
})

east_coast_sales_team = company.teams.create!({
  name: "East Coast Sales",
  leader: team_leader_users[0],
  parent: sales_team,
})

sharks_team = company.teams.create!({
  name: "Manhattan Sharks",
  leader: team_leader_users[0],
  parent: east_coast_sales_team,
})


team_member_users = company.users.create!([
  {
    first_name: "West Coast Member",
    last_name: "User",
    email: "west-coast-member@example.com",
    password: "password",
    team: west_coast_sales_team
  },
  {
    first_name: "East Coast Member",
    last_name: "User",
    email: "east-coast-member@example.com",
    password: "password",
    team: east_coast_sales_team
  },
  {
    first_name: "Shark Member",
    last_name: "User",
    email: "shark-member@example.com",
    password: "password",
    team: sharks_team
  }
])

# Time periods
time_periods = company.time_periods.create!([{
  name: 'Q3-2015',
  start_date: Time.parse('2015-07-01'),
  end_date: Time.parse('2015-09-30')
}, {
  name: 'Q4-2015',
  start_date: Time.parse('2015-10-01'),
  end_date: Time.parse('2015-12-31')
}, {
  name: 'Q1-2016',
  start_date: Time.parse('2016-01-01'),
  end_date: Time.parse('2016-03-31')
}, {
  name: 'Q2-2016',
  start_date: Time.parse('2016-04-01'),
  end_date: Time.parse('2016-06-30')
}, {
  name: 'Q3-2016',
  start_date: Time.parse('2016-07-01'),
  end_date: Time.parse('2016-09-30')
}])


# Set quotas for the initial time period
company_user.quotas.where(time_period: time_periods[2]).first.update_attributes(value: 1000000)
team_leader_users[0].quotas.where(time_period: time_periods[2]).first.update_attributes(value: 600000)
team_member_users[0].quotas.where(time_period: time_periods[2]).first.update_attributes(value: 200000)
team_member_users[1].quotas.where(time_period: time_periods[2]).first.update_attributes(value: 50000)
team_member_users[2].quotas.where(time_period: time_periods[2]).first.update_attributes(value: 350000)

company_clients = company.clients.create!([{
  name: "Buzzfeed",
  created_by: company_user.id,
  website: "buzzfeed.com",
  client_type: "Advertiser",
}, {
  name: "Digitas",
  created_by: company_user.id,
  website: "digitas.com",
  client_type: "Agency",
}, {
  name: "DistroScale",
  created_by: company_user.id,
  website: "distroscale.com",
  client_type: "Advertiser"
}])

# These client members will be used as the default for the deal_members when a deal is created
company_clients[0].client_members.create!([{
  user: team_member_users[0],
  share: 100,
  role: "Member"
}])

company_clients[2].client_members.create!([{
  user: team_leader_users[0],
  share: 10,
  role: "Leader"
},{
  user: team_member_users[2],
  share: 90,
  role: "Member"
}])

company.contacts.create!([{
  name: "Dan Walsh",
  position: "Director Sales Strategy",
  client: company_clients[0],
  created_by: company_user.id,
}, {
  name: "Bobby Jones",
  position: "CEO",
  client: company_clients[1],
  created_by: company_user.id,
}, {
  name: "Jillian Jackson",
  position: "Leader",
  client: company_clients[2],
  created_by: company_user.id,
}, {
  name: "Brian Bennett",
  position: "Sales Advisor",
  client: company_clients[1],
  created_by: company_user.id,
}])

# Deals
closed_deal = company.deals.create!({
  advertiser: company_clients[2],
  agency: company_clients[1],
  start_date: Time.parse('2015-01-01'),
  end_date: Time.parse('2015-03-31'),
  name: "Closed Deal",
  budget: 50000,
  stage: stages[5],
  deal_type: "Test Campaign",
  source_type: "Pitch to Agency",
  next_steps: "Deal complete.",
  created_by: company_user.id,
})

closed_deal.add_product(products[1].id, 50000)

prospecting_deal = company.deals.create!({
  advertiser: company_clients[2],
  agency: company_clients[1],
  start_date: Time.parse('2016-01-01'),
  end_date: Time.parse('2016-03-31'),
  name: "Prospecting Deal",
  budget: 255000,
  stage: stages[2],
  deal_type: "Seasonal",
  source_type: "Pitch to Client",
  next_steps: "Waiting on approval from finance.",
  created_by: company_user.id,
})

prospecting_deal.add_product(products[1], 2500000)
prospecting_deal.add_product(products[2], 5000)

# Revenue
csv =<<-eocsv
Order #,Line #,AdServer,Qty,Price,Price Type,Delivered Qty,Remaining Qty,Budget,Budget Remaining,Start Date,End Date,Advertiser,Advertiser ID,Sales Rep,Product ID
1234,1,DoubleClick,"10000",1.5,CPM,5000,"5000","15000",7500,7/1/2015,8/1/2015,#{company_clients[2]},#{company_clients[2].id},shark-member@example.com,#{products[2].id}
1234,2,DoubleClick,"20000",2,CPM,10000,"10000","40000",20000,7/1/2015,8/1/2015,#{company_clients[2]},#{company_clients[2].id},shark-member@example.com,#{products[2].id}
1234,3,DoubleClick,"10000",2.5,CPM,5000,"5000","25000",12500,7/1/2015,8/1/2015,#{company_clients[2]},#{company_clients[2].id},shark-member@example.com,#{products[2].id}
5656,1,DoubleClick,"10000",0.3,CPC,5000,"5000","3000",1500,6/1/2015,9/1/2015,#{company_clients[2]},#{company_clients[2].id},leader@example.com,#{products[2].id}
5656,2,DoubleClick,"20000",0.25,CPC,10000,"10000","5000",2500,7/1/2015,8/1/2015,#{company_clients[2]},#{company_clients[2].id},leader@example.com,#{products[2].id}
5656,3,DoubleClick,"50000",1,CPC,25000,"25000","50000",25000,6/1/2015,9/1/2015,#{company_clients[2]},#{company_clients[2].id},leader@example.com,#{products[2].id}
8686,1,Sizmek,100000,1,CPE,50000,50000,"100000",50000,9/1/2015,12/31/2015,#{company_clients[0]},#{company_clients[1].id},west-coast-member@example.com,#{products[1].id}
8686,2,Sizmek,100000,2,CPE,50000,50000,"200000",100000,9/2/2015,1/1/2016,#{company_clients[0]},#{company_clients[0].id},west-coast-member@example.com,#{products[1].id}
8686,3,Sizmek,100000,3,CPE,50000,50000,"300000",150000,9/3/2015,1/2/2016,#{company_clients[0]},#{company_clients[0].id},west-coast-member@example.com,#{products[1].id}
8686,4,Sizmek,100000,4,CPE,50000,50000,"400000",200000,9/4/2015,1/3/2016,#{company_clients[0]},#{company_clients[0].id},west-coast-member@example.com,#{products[1].id}
8686,5,Sizmek,100000,5,CPE,50000,50000,"500000",250000,9/5/2015,1/4/2016,#{company_clients[0]},#{company_clients[0].id},west-coast-member@example.com,#{products[1].id}
8686,6,Sizmek,100000,6,CPE,50000,50000,"600000",300000,9/6/2015,1/5/2016,#{company_clients[0]},#{company_clients[0].id},west-coast-member@example.com,#{products[1].id}
8686,7,Sizmek,100000,7,CPE,50000,50000,"700000",350000,9/7/2015,1/6/2016,#{company_clients[0]},#{company_clients[0].id},west-coast-member@example.com,#{products[1].id}
eocsv

revenues = Revenue.import(csv, company.id)
