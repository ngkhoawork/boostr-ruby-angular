class ProductForecastMemberSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes(
    :id,
    :name,
    :product,
    :stages,
    :weighted_pipeline,
    :weighted_pipeline_by_stage,
    :unweighted_pipeline_by_stage,
    :unweighted_pipeline,
    :revenue
  )
end

