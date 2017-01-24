@service.service 'ExchangeRate',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/exchange_rates/:id', { id: '@id'},
    save:
      method: 'POST'
      url: '/api/exchange_rates'
    update:
      method: 'PUT'
      url: '/api/exchange_rates/:id'

  @create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (data) ->
        deferred.resolve(data)
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update(
      params,
      (data) ->
        deferred.resolve(data)
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  return
]
