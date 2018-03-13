class DealMember < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :user
  belongs_to :username, -> { select(:id, :first_name, :last_name, :team_id) }, class_name: 'User', foreign_key: 'user_id'

  has_many :values, as: :subject

  validates :share, :user_id, :deal_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  delegate :email, to: :user

  scope :ordered_by_share, -> { order(share: :desc) }
  scope :not_account_manager_users, -> { includes(:user).where.not(users: {user_type: ACCOUNT_MANAGER}) }
  scope :account_manager_users, -> { includes(:user).where(users: {user_type: ACCOUNT_MANAGER}) }
  scope :with_not_zero_share, -> { where('share > ?', 0) }
  scope :by_seller, -> (seller_id) { where(user_id: seller_id) if seller_id.present? }
  scope :by_team, -> (team_id) { where(user_id: Team.find(team_id).all_members_and_leaders) if team_id.present? }
  scope :by_stage_ids, -> (stage_ids) { joins(:deal).where(deals: { stage_id: stage_ids }) if stage_ids.present? }

  after_update do
    log_share_changes if share_changed?
  end

  after_create do
    log_adding_member
  end

  after_destroy do |deal_member|
    log_destroying_member
  end

  set_callback :save, :after, :update_pipeline_fact_callback
  set_callback :destroy, :after, :remove_pipeline_fact_callback

  def update_pipeline_fact_callback
    update_pipeline_fact_user(self) if share_changed?
  end

  def remove_pipeline_fact_callback
    update_pipeline_fact_user(self) if self.share > 0
  end

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

  def update_pipeline_fact_user(deal_member)
    user = deal_member.user
    deal = deal_member.deal
    company = deal.company
    stage = deal.stage
    time_periods = company.time_periods.where("end_date >= ? and start_date <= ?", deal.start_date, deal.end_date)
    time_periods.each do |time_period|
      deal.deal_products.each do |deal_product|
        product = deal_product.product
        forecast_pipeline_fact_calculator = ForecastPipelineFactCalculator::Calculator.new(time_period, user, product, stage)
        forecast_pipeline_fact_calculator.calculate()
      end
    end
  end

  private

  def log_share_changes
    AuditLogService.new(
      record: deal,
      type: AuditLog::SHARE_CHANGE_TYPE,
      member: user_id,
      old_value: share_was,
      new_value: share
    ).perform
  end

  def log_adding_member
    AuditLogService.new(
      record: deal,
      type: AuditLog::MEMBER_ADDED_TYPE,
      member: user_id,
      new_value: user.name
    ).perform
  end

  def log_destroying_member
    AuditLogService.new(
      record: deal,
      type: AuditLog::MEMBER_REMOVED_TYPE,
      member: user_id,
      old_value: user.name
    ).perform
  end
end
