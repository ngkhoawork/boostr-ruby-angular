@service.service 'Search',
  ['$resource', '$q',
    ($resource, $q) ->

      resource = $resource '/api/search/:query', { query: '@query' }

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (pmps) ->
          deferred.resolve(pmps)
        deferred.promise

      return
  ]
