PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      any_word: true
    },
    dmetaphone: {
      any_word: true
    }
  },
  ranked_by: ':trigram'
}