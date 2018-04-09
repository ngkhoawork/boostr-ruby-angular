class StageSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :company_id,
    :deals_count,
    :color,
    :yellow_threshold,
    :red_threshold,
    :name,
    :probability,
    :open,
    :active,
    :position,
    :sales_process,
    :sales_process_id
  )

  def sales_process
    object.sales_process.serializable_hash(only: [:id, :name]) rescue nil
  end
end
