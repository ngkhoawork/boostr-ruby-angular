@service.service 'DataModel',
  ['$resource', '$q',
    ($resource, $q) ->

      resource = $resource '/api/data_models', {},
        query:
          isArray: false
        get_mappings:
          method: 'GET'
          url: '/api/data_models/data_mappings'
          isArray: true

      @all = (params) ->
        resource.query(params).$promise

      @get_mappings = (params) ->
        deferred = $q.defer()
        resource.get_mappings params,
          (resp) -> deferred.resolve(resp)
          (err) -> deferred.reject(err)
        deferred.promise

      return
  ]
