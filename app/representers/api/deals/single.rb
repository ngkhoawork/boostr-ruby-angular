class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :stage_name, :budget
  property :previous_stage, exec_context: :decorator
  property :created_at, as: :date, if: -> (options) { options[:new].eql? true }
  property :closed_at, as: :date, if: -> (options) { options[:new].eql? false }

  def previous_stage
    represented.try(:previous_stage).try(:name) || ''
  end
end
