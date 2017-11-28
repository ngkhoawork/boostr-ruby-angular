module Report
  module Publishers
    class AllFieldsService < Report::BaseService
      private

      def required_param_keys
        @required_option_keys ||= %i(company_id).freeze
      end

      def optional_param_keys
        @optional_option_keys ||= %i(publisher_stage_id team_id created_at page per).freeze
      end

      class ScopeBuilder < BaseScopeBuilder
        private

        def apply_filters
          PublishersQuery.new(@options).perform
        end

        def preload_associations(relation)
          relation.includes(:publisher_stage, :type, publisher_custom_field: { company: :publisher_custom_field_names })
        end
      end
    end
  end
end
