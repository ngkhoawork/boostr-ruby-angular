@service.service 'Search',
  ['$resource', '$q',
    ($resource, $q) ->

      resource = $resource '/api/search', {},
        getCount:
          method: 'GET'
          url: '/api/search/count'

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (res) ->
          deferred.resolve(res)
        deferred.promise

      @count = (params) ->
        deferred = $q.defer()
        resource.getCount params, (res) ->
          deferred.resolve(res)
        deferred.promise

      return
  ]
