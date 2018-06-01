namespace :global_search do
  desc 'build records for pg_search_documents table in db'
  task build_documents: :environment do
    PgSearch::Multisearch.rebuild(Client)
    PgSearch::Multisearch.rebuild(Deal)
    PgSearch::Multisearch.rebuild(Contact)
    PgSearch::Multisearch.rebuild(Io)
    PgSearch::Multisearch.rebuild(Activity)
  end

  desc 'delete all records in pg_search_documents table in db'
  task destroy_documents: :environment do
    PgSearch::Document.delete_all
  end
end
