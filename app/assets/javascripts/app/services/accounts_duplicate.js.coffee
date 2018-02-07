@service.service 'AccountsDuplicate',
[
  '$resource',
  ($resource) ->
    $resource('/api/clients/search_clients?name=:name&full_text_search=true', {name: '@name'})
]