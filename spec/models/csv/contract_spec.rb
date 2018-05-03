require 'rails_helper'

RSpec.describe Csv::Contract do
  describe '#perform' do 
    subject { csv_contract.perform }

    before do
      currency
    end

    context 'without duplicated data' do
      it 'creates new contract' do
        expect{subject}.to change{Contract.count}.by(1)
        contract = Contract.last
        expect(contract.name).to eq('contract')
        expect(contract.created_at.strftime('%m/%d/%Y')).to eq('05/02/2018')
        expect(contract.restricted).to be true
        expect(contract.status).to eq(status_option)
        expect(contract.auto_renew).to be true
        expect(contract.start_date.strftime('%m/%d/%Y')).to eq('05/01/2018')
        expect(contract.end_date.strftime('%m/%d/%Y')).to eq('06/30/2018')
        expect(contract.auto_notifications).to be false
        expect(contract.curr_cd).to eq('USD')
        expect(contract.amount).to eq(5000)
        expect(contract.description).to eq('this is test')
        expect(contract.days_notice_required).to eq(60)
        expect(contract.deal).to eq(deal)
        expect(contract.publisher).to eq(publisher)
        expect(contract.advertiser).to eq(advertiser)
        expect(contract.agency).to eq(agency)
        expect(contract.holding_company).to eq(holding_company)
      end
    end

    context 'with existing data' do
      before do 
        contract
      end

      it 'updates attributes' do
        expect{subject}.to change{contract.reload.amount}.from(1000).to(5000)
        expect{subject}.not_to change(Contract, :count)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def currency
    @_currency ||= create :currency
  end

  def contract
    @_contract ||= create :contract, company: company, type: type_option, name: 'contract', amount: '1000'
  end

  def type_field
    @_type_field ||= create :field, subject_type: 'Contract', name: 'Type', company: company
  end

  def type_option
    @_type_option ||= create :option, company: company, name: 'Contract Type 1', field: type_field
  end

  def status_field
    @_status_field ||= create :field, subject_type: 'Contract', name: 'Status', company: company
  end

  def status_option
    @_status_option ||= create :option, company: company, name: 'Contract Status 1', field: status_field
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def publisher
    @_publisher ||= create :publisher, company: company
  end

  def advertiser
    @_advertiser ||= create :client, :advertiser
  end

  def agency
    @_agency ||= create :client, :agency
  end

  def holding_company
    @_holding_company ||= create :holding_company
  end

  def csv_contract
    @_csv_contract ||= build :csv_contract, 
                              company: company, 
                              type_option: type_option,
                              name: 'contract', 
                              created_date: '05/02/2018',
                              restricted: '1',
                              status: status_option.name,
                              auto_renew: 'true',
                              start_date: '05/01/2018',
                              end_date: '06/30/2018',
                              auto_notifications: '0',
                              curr_cd: 'USD',
                              amount: 5000,
                              description: 'this is test',
                              days_notice_required: 60,
                              deal_name: deal.name,
                              deal_id: deal.id,
                              publisher_name: publisher.name,
                              advertiser_name: advertiser.name,
                              agency_name: agency.name,
                              agency_holding_name: holding_company.name
  end
end

RSpec.describe Csv::Contract, 'validations' do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type) }
  it { should validate_presence_of(:company_id) }
  it { should validate_numericality_of(:amount)}
  it { should validate_numericality_of(:days_notice_required)}

  it 'is valid with name and type' do
    csv_contract = build :csv_contract, company: company, type_option: type_option
    expect(csv_contract).to be_valid
  end

  it 'validates advertiser existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, advertiser_name: 'zhang'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Advertiser with --zhang-- name doesn\'t exist')
  end

  it 'validates agency existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, agency_name: 'zhang'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Agency with --zhang-- name doesn\'t exist')
  end

  it 'validates deal existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, deal_id: 0, deal_name: 'no exist'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Deal with --0-- ID and --no exist-- name doesn\'t exist')
  end

  it 'validates publisher existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, publisher_name: 'no exist'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Publisher with --no exist-- name doesn\'t exist')
  end

  it 'validates agency holding existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, agency_holding_name: 'no exist'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Agency holding with --no exist-- name doesn\'t exist')
  end

  it 'validates type existence' do
    csv_contract = build :csv_contract, company: company, type: 'no exist'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Contract type with --no exist-- name doesn\'t exist')
  end

  it 'validates status existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, status: 'no exist'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Contract status with --no exist-- name doesn\'t exist')
  end

  it 'validates currency existence' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, curr_cd: 'EUR'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Currency --EUR-- doesn\'t exist')
  end

  it 'validates created date format' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, created_date: '32/31/17'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Created date --32/31/17-- does not match mm/dd/yyyy format')
  end

  it 'validates created date format' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, start_date: '32/31/17'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('Start date --32/31/17-- does not match mm/dd/yyyy format')
  end

  it 'validates created date format' do
    csv_contract = build :csv_contract, company: company, type_option: type_option, end_date: '32/31/17'
    expect(csv_contract).not_to be_valid
    expect(csv_contract.errors.full_messages).to include('End date --32/31/17-- does not match mm/dd/yyyy format')
  end

  private

  def company
    @_company ||= create :company
  end

  def type_field
    @_type_field ||= create :field, subject_type: 'Contract', name: 'Type', company: company
  end

  def type_option
    @_type_option ||= create :option, company: company, name: 'Contract Type 1', field: type_field
  end

  def status_field
    @_status_field ||= create :field, subject_type: 'Contract', name: 'Status', company: company
  end

  def status_option
    @_status_option ||= create :option, company: company, name: 'Contract Status 1', field: status_field
  end
end
