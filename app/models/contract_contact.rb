class ContractContact < ActiveRecord::Base
  belongs_to :contract, required: true
  belongs_to :contact, required: true
  belongs_to :role, class_name: 'Option'
end
