class PublisherPipelineService < Report::BaseService
  def perform
    publisher_stages.inject([]) do |acc, publisher_stage|
      publishers = query_db(@params.merge(publisher_stage_id: publisher_stage.id))

      acc << {
        id: publisher_stage.id,
        publishers: decorate_publishers(publishers)
      }
    end
  end

  private

  def validate_params!(params)
    # Refuse if some of necessary params are absent
    if (required_param_keys - params.keys).present?
      raise ArgumentError, "some of required params (#{required_param_keys.join(', ')}) are missed"
    end
  end

  def required_param_keys
    @required_option_keys ||= %i(company_id).freeze
  end

  def publisher_stages
    Company.find(@params[:company_id]).publisher_stages
  end

  def decorate_publishers(publishers)
    publishers.map { |publisher| Api::Publishers::PipelineSerializer.new(publisher).as_json }
  end

  def query_db(params)
    ScopeBuilder.new(params).perform
  end

  class ScopeBuilder < BaseScopeBuilder
    def perform
      order(super)
    end

    private

    def apply_filters
      PublishersQuery.new(@options).perform
    end

    def preload_associations(relation)
      relation.includes(:users)
    end

    def order(relation)
      relation.order(name: :asc)
    end
  end
end
