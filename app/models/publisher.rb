class Publisher < ActiveRecord::Base
  acts_as_paranoid

  has_one :address, as: :addressable, dependent: :destroy
  has_many :activities
  has_many :contacts
  has_many :publisher_members, dependent: :destroy
  has_many :users, through: :publisher_members
  has_many :sales_stage, as: :sales_stageable

  belongs_to :clients

  validate :name, :client_id, presence: true 
end
