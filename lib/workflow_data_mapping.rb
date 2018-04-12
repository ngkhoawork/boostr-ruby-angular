class WorkflowDataMapping
  attr_reader :base_klass

  def initialize(base_klass)
    @base_klass = base_klass
  end

  def allowed_reflections
    all_reflections.select do |reflection|
      base_klass_const.workflowable_reflections.include? reflection.name
    end
  end

  def all_reflections
    base_klass_const.reflect_on_all_associations
  end

  def base_klass_const
    base_klass.constantize
  end
end
