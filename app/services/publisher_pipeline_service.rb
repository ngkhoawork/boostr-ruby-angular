class PublisherPipelineService < Report::BaseService
  def perform
    publisher_stages.inject([]) do |acc, publisher_stage|
      publishers = query_db(@params.merge(publisher_stage_id: publisher_stage.id))

      acc << {
        id: publisher_stage.id,
        name: publisher_stage.name,
        probability: publisher_stage.probability,
        estimated_monthly_impressions_sum: calculate_sum_for(publishers, :estimated_monthly_impressions),
        actual_monthly_impressions_sum: calculate_sum_for(publishers, :actual_monthly_impressions),
        publishers: decorate_publishers(publishers)
      }
    end
  end

  private

  def required_param_keys
    @required_option_keys ||= %i(company_id).freeze
  end

  def optional_param_keys
    @optional_option_keys ||=
      %i(q comscore publisher_stage_id type_id team_id my_publishers_bool my_team_publishers_bool current_user page per).freeze
  end

  def publisher_stages
    Company.find(@params[:company_id]).publisher_stages
  end

  def decorate_publishers(publishers)
    publishers.map { |publisher| Api::Publishers::PipelineSerializer.new(publisher).as_json }
  end

  def calculate_sum_for(publishers, field_name)
    publishers.inject(0) do |sum, publisher|
      field_value = publisher.send(field_name)
      field_value ? (sum + field_value) : sum
    end
  end

  def query_db(params)
    ScopeBuilder.new(params).perform
  end

  class ScopeBuilder < BaseScopeBuilder
    private

    def apply_filters
      PublishersQuery.new(@options).perform
    end

    def preload_associations(relation)
      relation.includes(:users)
    end
  end
end
