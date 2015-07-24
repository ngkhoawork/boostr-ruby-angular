class Client < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :contacts
  has_many :revenue

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true

  def as_json(options = {})
    super(options.merge(include: [:address]))
  end
end
