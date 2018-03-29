class Emails::ContractDecorator
  BLANK = '-'.freeze

  def self.field_names
    EalertTemplate::Contract.field_names
  end

  def initialize(record)
    @record = record
  end

  delegate :field_names, to: :class
  delegate :name, :description, :start_date, :end_date, :amount, :restricted, to: :@record

  def collect
    field_names.each.with_object({}) { |field_name, acc| acc[field_name] = public_send(field_name) }
  end

  def advertiser
    @record.advertiser&.name
  end

  def agency
    @record.agency&.name
  end

  def deal
    @record.deal&.name
  end

  def publisher
    @record.publisher&.name
  end

  def holding_company
    @record.holding_company&.name
  end

  def type
    @record.type&.name
  end

  def status
    @record.status&.name
  end

  def currency
    @record.curr_cd
  end

  field_names.each do |method_name|
    alias_method "old_#{method_name}", method_name

    define_method(method_name) do
      public_send("old_#{method_name}") || BLANK
    end
  end
end
