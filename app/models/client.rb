class Client < ActiveRecord::Base
  belongs_to :company

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true

  def as_json(options = {})
    super(options.merge(include: [:address]))
  end
end
