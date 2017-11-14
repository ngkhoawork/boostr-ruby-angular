class Publisher < ActiveRecord::Base
  acts_as_paranoid

  has_one :address, as: :addressable, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :contacts
  has_many :publisher_members, dependent: :destroy
  has_many :users, through: :publisher_members
  has_many :sales_stage, as: :sales_stageable
  has_many :values, as: :subject

  belongs_to :client

  validates :name, :client_id, presence: true
  validates :website, format: { with: REGEXP_FOR_URL, message: 'Valid URL required' }
end
