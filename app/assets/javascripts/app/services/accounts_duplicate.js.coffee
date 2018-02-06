@service.service 'AccountsDuplicate',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/clients/suggest_clients?full_text_search=true'

  @all = ->
    deferred = $q.defer()
    resource.query {}, (suggest_clients) ->
      deferred.resolve(suggest_clients)
    deferred.promise

  return
]