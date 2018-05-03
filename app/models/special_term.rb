class SpecialTerm < ActiveRecord::Base
  belongs_to :contract, required: true
  belongs_to :name, class_name: 'Option'
  belongs_to :type, class_name: 'Option'
end
