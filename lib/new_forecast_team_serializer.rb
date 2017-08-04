class NewForecastTeamSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :parents,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :weighted_pipeline,
    :revenue,
    :amount,
    :percent_to_quota,
    :percent_booked,
    :gap_to_quota,
    :quota,
    :wow_revenue,
    :wow_weighted_pipeline,
    :type,
    :teams,
    :leader,
    :members,
    :all_teammembers,
    :new_deals_needed,
  )


  def year_value
    object.year || object.start_date.year rescue nil
  end

  def quarter_number
    if object.start_date.present? && object.end_date.present? && (object.end_date - object.start_date).to_i < 100
      1 + ((object.start_date.month - 1)/3).to_i
    end
  end
end
