class PacingDashboard::ActivityPacingSerializer < ActiveModel::Serializer
	attribute :current_week

	has_many :teams, serializer: PacingDashboard::TeamSerializer
	has_many :sellers, serializer: PacingDashboard::SellerSerializer
	has_many :products, serializer: PacingDashboard::ProductSerializer

	private

	def teams
		object.teams
	end

	def sellers
		object.users.where(user_type: SELLER)
	end

	def products
		object.products
  end

  def current_week
    TimePeriodWeek.current_week_number if current_time_period?
	end

	def time_period_id
		options[:time_period_id]
	end

	def current_time_period?
		time_period_id.blank? || TimePeriod.current_quarter.id.eql?(time_period_id.to_i)
	end
end
