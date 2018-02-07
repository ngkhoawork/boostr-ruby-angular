@service.service 'AccountsDuplicate',
[
  '$resource',
  ($resource) ->
    $resource('/api/clients?name=:name&full_text_search=true', {name: '@name'})
]