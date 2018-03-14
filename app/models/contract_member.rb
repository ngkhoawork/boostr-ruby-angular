class ContractMember < ActiveRecord::Base
  belongs_to :contract, required: true
  belongs_to :user, required: true
  belongs_to :role, class_name: 'Option'
end
