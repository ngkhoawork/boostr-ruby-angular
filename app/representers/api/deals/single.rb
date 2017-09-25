class API::Deals::Single < API::Single
  include ActionView::Helpers::NumberHelper

  properties :id, :name, :advertiser_name, :start_date
  property :new_value, exec_context: :decorator, if: -> (options) { options[:new].eql? false }
  property :old_value, exec_context: :decorator, if: -> (options) { options[:new].eql? false }
  property :created_by, as: :changed_by, exec_context: :decorator, if: -> (options) { options[:new].eql? true }
  property :updated_by, as: :changed_by, exec_context: :decorator, if: -> (options) { options[:new].eql? false }
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

  def created_by
    User.find(represented.created_by).name
  end

  def updated_by
    User.find(represented.updated_by).name
  end
end
