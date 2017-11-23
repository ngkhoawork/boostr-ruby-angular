@service.service 'TempIO',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        original.temp_io.values_attributes = original.temp_io.values
        angular.toJson(original)

      resource = $resource '/api/temp_ios/:id', { id: '@id' },
        update:
          method: 'PUT'
          url: '/api/temp_ios/:id'
          transformRequest: transformRequest

      currentTempIO = undefined

      @query = resource.query

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (tempIOs) ->
          deferred.resolve(tempIOs)
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update params, (tempIO) ->
          deferred.resolve(tempIO)
          $rootScope.$broadcast 'updated_temp_ios'
        deferred.promise

      @get = (temp_io_id) ->
        deferred = $q.defer()
        resource.get id: temp_io_id, (tempIO) ->
          deferred.resolve(tempIO)
        deferred.promise

      return
  ]
