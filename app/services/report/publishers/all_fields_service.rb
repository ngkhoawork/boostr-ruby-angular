module Report
  module Publishers
    class AllFieldsService < Report::BaseService
      private

      def required_param_keys
        @required_option_keys ||= %i(company_id).freeze
      end

      def optional_param_keys
        @optional_option_keys ||= %i(publisher_stage_id team_id created_at page per_page).freeze
      end

      class ScopeBuilder
        def initialize(options)
          @options = options
        end

        def perform
          preload_associations(
            paginate(
              apply_filters
            )
          )
        end

        private

        def apply_filters
          PublishersQuery.new(@options).perform
        end

        def paginate(relation)
          @options[:page] ? relation.offset(offset).limit(per_page) : relation
        end

        def preload_associations(relation)
          relation.includes(:publisher_stage, :type, publisher_custom_field: { company: :publisher_custom_field_names })
        end

        def per_page
          @options[:per_page].to_i > 0 ? @options[:per_page].to_i : 10
        end

        def offset
          (page - 1) * per_page
        end

        def page
          @options[:page].to_i > 0 ? @options[:page].to_i : 1
        end
      end
    end
  end
end
