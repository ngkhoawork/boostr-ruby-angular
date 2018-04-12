class CsvImportLogSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :file_source,
    :object_name,
    :rows_failed,
    :rows_imported,
    :rows_processed,
    :rows_skipped,
    :created_at,
    :source
  )

  attribute :error_messages

  def include_error_messages?
    options[:template] == 'show'
  end
end
