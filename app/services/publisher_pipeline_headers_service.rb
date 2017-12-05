class PublisherPipelineHeadersService < Report::BaseService
  def perform
    publisher_stages.inject([]) do |acc, publisher_stage|
      publishers = query_db(@params.merge(publisher_stage_id: publisher_stage.id)).to_a

      acc << {
        id: publisher_stage.id,
        name: publisher_stage.name,
        probability: publisher_stage.probability,
        estimated_monthly_impressions_sum: calculate_sum_for(publishers, :estimated_monthly_impressions),
        actual_monthly_impressions_sum: calculate_sum_for(publishers, :actual_monthly_impressions),
        publishers_count: publishers.count
      }
    end
  end

  private

  def required_param_keys
    @required_option_keys ||= %i(company_id).freeze
  end

  def optional_param_keys
    @optional_option_keys ||=
      %i(q comscore type_id team_id my_publishers_bool my_team_publishers_bool current_user).freeze
  end

  def publisher_stages
    Company.find(@params[:company_id]).publisher_stages
  end

  def calculate_sum_for(publishers, field_name)
    publishers.inject(0) do |sum, publisher|
      field_value = publisher.send(field_name)
      field_value ? (sum + field_value) : sum
    end
  end

  def query_db(params)
    PublishersQuery.new(params).perform
  end
end
