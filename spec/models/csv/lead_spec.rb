require 'rails_helper'

describe Csv::Lead do
  it 'create new lead' do
    expect {
      Csv::Lead.import(file, user.id, 'lead.csv')
    }.to change(Lead, :count).by(1)

    lead = Lead.last

    expect(lead.first_name).to eq('John')
    expect(lead.last_name).to eq('Doe')
    expect(lead.title).to eq('Director')
    expect(lead.email).to eq(contact.email)
    expect(lead.company_name).to eq('Apple')
    expect(lead.country).to eq('USA')
    expect(lead.state).to eq('Arizona')
    expect(lead.budget).to eq('20-30k')
    expect(lead.status).to eq('new')
  end

  it 'failed to create new lead' do
    expect {
      Csv::Lead.import(invalid_file, user.id, 'lead.csv')
    }.not_to change(Lead, :count)
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def contact
    @_contact ||= create :contact, company: company
  end

  def file
    @_file = CSV.generate do |csv|
      csv << file_headers
      csv << ['John', 'Doe', 'Director', contact.email, 'Apple', 'USA', 'Arizona', '20-30k', 'new', 'false']
    end
  end

  def invalid_file
    @_invalid_file = CSV.generate do |csv|
      csv << file_headers
      csv << ['', '', 'Director', contact.email, 'Apple', 'USA', 'Arizona', '20-30k', 'new', 'false']
    end
  end

  def file_headers
    [
      'First Name',
      'Last Name',
      'Title',
      'Sender Email',
      'Company Name',
      'Country',
      'State',
      'Budget',
      'Status',
      'Skip Assignment'
    ]
  end
end
