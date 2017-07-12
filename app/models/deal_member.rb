class DealMember < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :user
  belongs_to :username, -> { select(:id, :first_name, :last_name) }, class_name: 'User', foreign_key: 'user_id'

  has_many :values, as: :subject

  validates :share, :user_id, :deal_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  delegate :email, to: :user

  scope :ordered_by_share, -> { order(share: :desc) }
  scope :not_account_manager_users, -> { includes(:user).where.not(users: {user_type: ACCOUNT_MANAGER}) }
  scope :with_not_zero_share, -> { where('share > ?', 0) }
  scope :by_seller, -> (seller_id) { where(user_id: seller_id) if seller_id.present? }
  scope :by_team, -> (team_id) { where(users: { team_id: team_id }) if team_id.present? }
  scope :by_stage_ids, -> (stage_ids) { joins(:deal).where(deals: { stage_id: stage_ids }) if stage_ids.present? }

  def name
    user.name if user.present?
  end

  def as_json(options = {})
    super(options.merge(include: [values: { include: [:option], methods: [:value] }]))
  end

  def fields
    user.company.fields.where(subject_type: 'Client')
  end

  def self.emails_for_users_except_account_manager_user_type
    not_account_manager_users.ordered_by_share.pluck(:email)
  end
end
