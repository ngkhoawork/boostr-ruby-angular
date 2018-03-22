module Dataexport
  module CommonFields
    module TimestampFields
      def created
        object.created_at
      end

      def last_updated
        object.updated_at
      end
    end
  end
end
