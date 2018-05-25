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
    relatedAccounts: {
      method: 'GET'
      url: '/api/holding_companies/:id/account_dimensions'
      isArray: true
    }
    relatedAccountsWithoutHolding: {
      method: 'GET'
      url: '/api/account_dimensions'
      isArray: true
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

  @relatedAccounts = ( id, search = '', agencyIDs = [] ) ->
    resource.relatedAccounts( { id: id, search: search, 'exclude_ids[]': agencyIDs } ).$promise

  @relatedAccountsWithoutHolding = (search = '', agencyIDs = [] ) ->
    resource.relatedAccountsWithoutHolding( { search: search, 'exclude_ids[]': agencyIDs } ).$promise

  return
]
