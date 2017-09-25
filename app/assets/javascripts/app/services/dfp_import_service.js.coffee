@service.service 'DfpImportService',
  ['$resource', '$q',
    ($resource, $q) ->
      resource = $resource 'api/dfp_imports/import'
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