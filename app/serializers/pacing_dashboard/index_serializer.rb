class PacingDashboard::IndexSerializer < ActiveModel::Serializer
  has_many :teams, serializer: PacingDashboard::TeamSerializer
  has_many :sellers, serializer: PacingDashboard::SellerSerializer
  has_many :time_periods, serializer: PacingDashboard::TimePeriodSerializer
  has_many :products, serializer: PacingDashboard::ProductSerializer

  private

  def teams
    object.teams
  end

  def sellers
    object.users.where(user_type: SELLER)
  end

  def time_periods
    object.time_periods.all_quarter
  end

  def products
    object.products
  end
end
