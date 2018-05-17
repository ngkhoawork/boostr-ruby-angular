class BuildSearchDocuments < ActiveRecord::Migration
  def up
    PgSearch::Multisearch.rebuild(Client)
    PgSearch::Multisearch.rebuild(Deal)
    PgSearch::Multisearch.rebuild(Contact)
    PgSearch::Multisearch.rebuild(Io)
  end

  def down
    PgSearch::Document.delete_all
  end
end
