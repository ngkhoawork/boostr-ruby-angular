class PgSearchDocumentUpdateWorker < BaseWorker
  def perform(klass, ids)
    klass.constantize.where(id: ids).each do |object|
      object.update_pg_search_document
    end
  end
end
