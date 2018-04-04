class ForecastPipelineFact < ActiveRecord::Base
  belongs_to :forecast_time_dimension
  belongs_to :user_dimension
  belongs_to :product_dimension
  belongs_to :stage_dimension

  scope :by_time_dimension_id, -> (time_dimension_id) do
    where('forecast_time_dimension_id = ?', time_dimension_id) if time_dimension_id
  end
  scope :by_user_dimension_ids, -> (user_dimension_ids) do
    if user_dimension_ids && user_dimension_ids.count > 0
      where('user_dimension_id in (?)', user_dimension_ids)
    end
  end
  scope :by_product_dimension_ids, -> (product_dimension_ids) do
    if product_dimension_ids && product_dimension_ids.count > 0
      where('product_dimension_id in (?)', product_dimension_ids)
    end
  end
  scope :zero_amount, ->{ where(amount: 0) }
end
