class Report::RevenueByCategorySerializer < ActiveModel::Serializer
  ATTRIBUTES = %i(category_id region_id segment_id year revenues total_revenue).freeze

  attributes *ATTRIBUTES

  def attributes(*args)
    super(*args).compact
  end

  ATTRIBUTES.each do |attr|
    define_method(attr) do
      object.try(attr)
    end
  end
end
