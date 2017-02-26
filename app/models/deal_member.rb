class DealMember < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :user
  belongs_to :username, -> { select(:id, :first_name, :last_name) }, class_name: 'User', foreign_key: 'user_id'

  has_many :values, as: :subject

  validates :share, :user_id, :deal_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

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
