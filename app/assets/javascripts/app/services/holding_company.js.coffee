@service.service 'HoldingCompany',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/holding_companies/:id', { id: '@id' },
    get: {
      method: 'GET',
      cache: true
    },
    save: {
      method: 'POST'
      url: '/api/holding_companies'
    },
    update: {
      method: 'PUT'
      url: '/api/holding_companies/:id'
    }

  holding_companies = []

  @all = (params) ->
    deferred = $q.defer()
    if holding_companies.length == 0
      resource.query params, (data) =>
        holding_companies = data
        deferred.resolve(holding_companies)
    else
      deferred.resolve(holding_companies)
    deferred.promise
  
  return
]
