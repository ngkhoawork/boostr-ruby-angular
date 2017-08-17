class API::Deals::Single < API::Single
  properties :id, :name, :advertiser_name, :start_date, :budget
  property :new_value, exec_context: :decorator
  property :old_value, exec_context: :decorator
  property :created_at, as: :date, if: -> (options) { options[:new].eql? true }
  property :closed_at, as: :date, if: -> (options) { options[:new].eql? false }

  def new_value
    represented.stage_name
  end

  def old_value
    represented.previous_stage.name rescue nil
  end
end
