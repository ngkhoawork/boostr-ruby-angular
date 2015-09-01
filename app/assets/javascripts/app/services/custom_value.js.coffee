@service.service 'CustomValue',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/custom_values/'

  @all = ->
    deferred = $q.defer()
    resource.query {}, (custom_values) ->
      deferred.resolve(custom_values)
    deferred.promise

  return
]