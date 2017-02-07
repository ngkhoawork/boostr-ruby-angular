class DealMember < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :user

  has_many :values, as: :subject

  validates :share, :user_id, :deal_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  delegate :email, to: :user

  scope :ordered_by_share, -> { order(share: :desc) }

  def name
    user.name if user.present?
  end

  def as_json(options = {})
    super(options.merge(include: [values: { include: [:option], methods: [:value] }]))
  end

  def fields
    user.company.fields.where(subject_type: 'Client')
  end
end
