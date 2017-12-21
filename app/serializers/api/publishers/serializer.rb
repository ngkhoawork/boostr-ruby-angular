class Api::Publishers::Serializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :type,
    :client_id,
    :created_at,
    :updated_at,
    :publisher_members,
    :revenue_share,
    :term_start_date,
    :term_end_date,
    :renewal_term,
    :revenue_ytd
  )

  has_one :publisher_stage, serializer: Api::Publishers::StageSerializer

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end

  def renewal_term
    object.renewal_term&.serializable_hash(only: [:id, :name])
  end

  def publisher_members
    object.publisher_members.includes(:user).map do |member|
      Api::Publishers::MembersSerializer.new(member).as_json
    end
  end

  def revenue_ytd
    daily_actuals_for_current_year.sum(:total_revenue)
  end

  def daily_actuals_for_current_year
    daily_actuals.by_date(current_date.beginning_of_year, current_date)
  end

  def current_date
    @_current_month ||= Date.today
  end

  def actual_monthly_impressions
    daily_actuals.sum(:available_impressions) / 3 rescue nil
  end

  def daily_actuals
    @_daily_actuals ||= object.daily_actuals
                              .by_date(current_date - 90.days, Date.current)
  end
end
