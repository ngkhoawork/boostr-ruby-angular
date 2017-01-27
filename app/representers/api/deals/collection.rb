class API::Deals::Collection < API::Collection
  collection :entries, extend: API::Deals::Single, as: :deals
end