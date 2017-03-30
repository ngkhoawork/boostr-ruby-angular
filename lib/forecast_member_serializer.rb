class ForecastMemberSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :revenue,
    :amount,
    :percent_to_quota,
    :percent_booked,
    :gap_to_quota,
    :quota,
    :wow_revenue,
    :wow_weighted_pipeline,
    :is_leader,
    :year,
    :quarter,
    :new_deals_needed,
    :type
  )

  def quarter
    object.quarter || quarter_number rescue nil
  end

  def year
    object.year || object.start_date.year rescue nil
  end

  def quarter_number
    if (object.end_date - object.start_date).to_i < 100
      1 + ((object.start_date.month - 1)/3).to_i
    end
  end
end
