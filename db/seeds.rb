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

team_leader_users = User.create!([
  {
    first_name: "Leader",
    last_name: "User",
    email: "leader@example.com",
    password: "password"
  }
])

team_member_users = User.create!([
  {
    first_name: "Member",
    last_name: "User",
    email: "member@example.com",
    password: "password"
  }
])

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

Product.create!([
  { company: company, name: "Video", product_line: "Phone", family: "Native", pricing_type: "CPM" },
  { company: company, name: "Native Ad - Mobile", product_line: "Tablet", family: "Banner",  pricing_type: "CPC" },
  { company: company, name: "Native Ad - Desktop", product_line: "Desktop", family: "Native", pricing_type: "CPC" }
])

# Stages

# Teams
# Clients
# Contacts
# Deals
# Time periods
# Quotas
