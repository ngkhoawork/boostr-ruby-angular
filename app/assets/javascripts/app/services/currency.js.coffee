@service.service 'Currency',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/currencies', {},
    active_currencies:
      method: 'GET'
      isArray: true
      url: 'api/currencies/active_currencies'
    exchange_rates_by_currencies:
      method: 'GET'
      isArray: true
      url: 'api/currencies/exchange_rates_by_currencies'

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @active_currencies = (params) ->
    deferred = $q.defer()
    resource.active_currencies params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @exchange_rates_by_currencies = (params) ->
    deferred = $q.defer()
    resource.exchange_rates_by_currencies params, (data) ->
      deferred.resolve(data)
    deferred.promise

  return
]
