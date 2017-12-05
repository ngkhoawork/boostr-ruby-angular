module Report
  module Publishers
    class AllFieldsService < Report::BaseService
      private

      def required_param_keys
        @required_option_keys ||= %i(company_id).freeze
      end

      def optional_param_keys
        @optional_option_keys ||= %i(publisher_stage_id team_id created_at_start created_at_end page per_page).freeze
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
          relation.includes(
            :publisher_stage,
            :type,
            :client,
            users: :team,
            publisher_custom_field: {
              company: :publisher_custom_field_names
            }
          )
        end

        def order(relation)
          relation.order(name: :asc)
        end
      end
    end
  end
end
