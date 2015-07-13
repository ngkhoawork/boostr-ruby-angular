class Contact < ActiveRecord::Base
  belongs_to :client
  belongs_to :company

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true
  validates :position, presence: true

  def as_json(options = {})
    super(options.merge(include: [:address, :client, :company]))
  end
end
