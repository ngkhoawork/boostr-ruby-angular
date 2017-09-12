class NewQuarterlyForecastSerializer < ActiveModel::Serializer
  attributes(
    :forecast,
    :quarters
  )

end

