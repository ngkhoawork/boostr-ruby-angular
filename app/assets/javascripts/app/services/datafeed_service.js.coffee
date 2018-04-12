@service.service 'DatafeedService',
  ['$resource', '$q',
    ($resource, $q) ->
      resource = $resource 'api/datafeed/import'
      @import = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (data) ->
            deferred.resolve(data)
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise
      return
  ]
