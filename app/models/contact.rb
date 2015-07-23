class Contact < ActiveRecord::Base
  belongs_to :client
  belongs_to :company

  has_one :address, as: :addressable

  accepts_nested_attributes_for :address

  validates :name, presence: true
  validates :position, presence: true

  scope :for_client, -> client_id { where(client_id: client_id) if client_id.present? }

  def as_json(options = {})
    super(options.merge(include: [:address, :client, :company]))
  end
end
