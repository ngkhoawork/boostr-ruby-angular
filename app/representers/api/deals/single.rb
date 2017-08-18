class API::Deals::Single < API::Single
  include ActionView::Helpers::NumberHelper

  properties :id, :name, :advertiser_name, :start_date
  property :new_value, exec_context: :decorator
  property :old_value, exec_context: :decorator
  property :budget, exec_context: :decorator
  property :created_at, as: :date, if: -> (options) { options[:new].eql? true }
  property :closed_at, as: :date, if: -> (options) { options[:new].eql? false }

  def new_value
    represented.stage_name
  end

  def old_value
    represented.previous_stage.name rescue nil
  end

  def budget
    number_to_currency(represented.budget, precision: 0)
  end
end
