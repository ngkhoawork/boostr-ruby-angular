class Contract < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :deal
  belongs_to :advertiser
  belongs_to :agency
  belongs_to :publisher
  belongs_to :type, class_name: 'Option'
  belongs_to :status, class_name: 'Option'

  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  has_one :type_field, -> { where(subject_type: 'Contract', name: 'Type') }, through: :company, source: :fields
  has_one :status_field, -> { where(subject_type: 'Contract', name: 'Status') }, through: :company, source: :fields

  validates :name, :start_date, :end_date, presence: true
end
