class Csv::ContractSpecialTerm
  include ActiveModel::Validations

  attr_accessor :contract_id, 
                :contract_name, 
                :term_name, 
                :term_type, 
                :comments, 
                :company_id

  validates_presence_of :contract_name, :term_name, :company_id
  validate :validate_contract_existence
  validate :validate_term_name_existence
  validate :validate_term_type_existence

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    contract.special_terms.new.tap do |t|
      t.name = name
      t.type = type
      t.comment = comments
      t.save!
    end
  end

  private

  def company
    @_company ||= Company.find_by(id: company_id)
  end

  def contract
    @_contract ||= if contract_id.present?
      company&.contracts&.find_by(id: contract_id, name: contract_name)
    else
      company&.contracts&.find_by(name: contract_name)
    end
  end

  def name
    @_name ||= company&.fields&.find_by(subject_type: 'Contract', name: 'Special Term Name', value_type: 'Option')
      &.options&.find_by(name: term_name)
  end

  def type
    @_type ||= company&.fields&.find_by(subject_type: 'Contract', name: 'Special Term Type', value_type: 'Option')
      &.options&.find_by(name: term_type)
  end

  def validate_contract_existence
    if contract.nil? && contract_id.present?
      errors.add(:base, "Contract with --#{contract_id}-- ID and --#{contract_name}-- name doesn't exist")
    elsif contract.nil?
      errors.add(:base, "Contract with --#{contract_name}-- name doesn't exist")
    end
  end

  def validate_term_name_existence
    if name.nil?
      errors.add(:base, "Term name --#{term_name}-- doesn't exist")
    end
  end

  def validate_term_type_existence
    if term_type.present? && type.nil?
      errors.add(:base, "Term type --#{term_type}-- doesn't exist")
    end
  end
end