class ContractContact < ActiveRecord::Base
  belongs_to :contract, required: true
  belongs_to :contact, required: true
end
