@service.service 'Company',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/company', {},
    update: {
      method: 'PUT'
      url: '/api/company'
    }

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (company) ->
      deferred.resolve(company)
    deferred.promise

  @get = () ->
    deferred = $q.defer()
    resource.get {}, (company) ->
      deferred.resolve(company)
    deferred.promise

  return
]
