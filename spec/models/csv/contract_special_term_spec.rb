require 'rails_helper'

RSpec.describe Csv::ContractSpecialTerm do
  describe '#perform' do 
    subject { csv_contract_special_term.perform }

    it 'creates new contract special term' do
      expect{subject}.to change{SpecialTerm.count}.by(1)
      special_term = SpecialTerm.last
      expect(special_term.name).to eq(special_term_name_option)
      expect(special_term.type).to eq(special_term_type_option)
      expect(special_term.comment).to eq('testing now')
      expect(special_term.contract).to eq(contract)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def contract
    @_contract ||= create :contract, company: company, type: type_option
  end

  def type_field
    @_type_field ||= create :field, subject_type: 'Contract', name: 'Type', company: company
  end

  def type_option
    @_type_option ||= create :option, company: company, name: 'Contract Type 1', field: type_field
  end

  def special_term_name_field
    @_special_term_name_field ||= create :field, company: company, subject_type: 'Contract', name: 'Special Term Name', value_type: 'Option'
  end

  def special_term_name_option
    @_special_term_name_option ||= create :option, company: company, name: 'Term Name 1', field: special_term_name_field
  end

  def special_term_type_field
    @_special_term_type_field ||= create :field, company: company, subject_type: 'Contract', name: 'Special Term Type', value_type: 'Option'
  end

  def special_term_type_option
    @_special_term_type_option ||= create :option, company: company, name: 'Term Type 1', field: special_term_type_field
  end

  def csv_contract_special_term
    @_csv_contract_special_term ||= build :csv_contract_special_term,
                              contract: contract,
                              company: company,
                              name_option: special_term_name_option,
                              term_type: special_term_type_option.name,
                              comments: 'testing now'
  end
end

RSpec.describe Csv::ContractSpecialTerm, 'validations' do
  it { should validate_presence_of(:contract_name) }
  it { should validate_presence_of(:term_name) }
  it { should validate_presence_of(:company_id) }

  it 'is valid with contract name and term type' do
    csv_contract_special_term = build :csv_contract_special_term, company: company, name_option: name_option, contract: contract
    expect(csv_contract_special_term).to be_valid
  end

  it 'validates contract existence' do
    csv_contract_special_term = build :csv_contract_special_term, company: company, name_option: name_option, contract_name: 'no exist'
    expect(csv_contract_special_term).not_to be_valid
    expect(csv_contract_special_term.errors.full_messages).to include('Contract with --no exist-- name doesn\'t exist')
  end

  it 'validates term name existence' do
    csv_contract_special_term = build :csv_contract_special_term, company: company, contract: contract, term_name: 'no exist'
    expect(csv_contract_special_term).not_to be_valid
    expect(csv_contract_special_term.errors.full_messages).to include('Term name --no exist-- doesn\'t exist')
  end

  it 'validates term type existence' do
    csv_contract_special_term = build :csv_contract_special_term, company: company, name_option: name_option, contract: contract, term_type: 'no exist'
    expect(csv_contract_special_term).not_to be_valid
    expect(csv_contract_special_term.errors.full_messages).to include('Term type --no exist-- doesn\'t exist')
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

  def special_term_name_field
    @_special_term_name_field ||= create :field, company: company, subject_type: 'Contract', name: 'Special Term Name', value_type: 'Option'
  end

  def name_option
    @_name_option ||= create :option, company: company, name: 'Term Name 1', field: special_term_name_field
  end

  def contract
    @_contract ||= create :contract, company: company, type: type_option
  end
end
