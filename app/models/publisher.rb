class Publisher < ActiveRecord::Base
  acts_as_paranoid

  has_one :address, as: :addressable, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :contacts
  has_many :publisher_members, dependent: :destroy
  has_many :users, through: :publisher_members
  has_many :sales_stage, as: :sales_stageable

  has_many :values, as: :subject
  has_one :type_field, -> { where(subject_type: 'Publisher', name: 'Publisher Type') },
          through: :company, source: :fields
  has_many :available_options, through: :type_field, source: :options
  has_one :type_value, through: :type_field, source: :values, foreign_key: :subject_id
  has_one :type_option, through: :type_value, source: :option

  belongs_to :client
  belongs_to :company

  validates :name, :client_id, presence: true
  validates :website, format: { with: REGEXP_FOR_URL, message: 'Valid URL required', multiline: true }
end
