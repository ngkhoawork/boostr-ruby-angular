@service.service 'IO',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        original.io.values_attributes = original.io.values
        angular.toJson(original)

      transformAddContactRequest = (original, headers) ->
        # original.io.values_attributes = original.io.values
        console.log 'original:', original
        angular.toJson(original.params)

      resource = $resource '/api/ios/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/ios'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/ios/:id'
          transformRequest: transformRequest
        update_influencer_budget:
          method: 'PUT'
          url: '/api/ios/:id/update_influencer_budget'
        updateContacts:
          method: 'PUT'
          url: 'api/ios/:id'
          transformRequest: transformAddContactRequest

      currentIO = undefined

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (ios) ->
          deferred.resolve(ios)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (io) ->
            deferred.resolve(io)
            $rootScope.$broadcast 'updated_ios'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (io) ->
            deferred.resolve(io)
            $rootScope.$broadcast 'updated_ios'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update_influencer_budget = (params) ->
        deferred = $q.defer()
        resource.update_influencer_budget(
          params,
          (io) ->
            deferred.resolve(io)
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @updateContacts = (id, params) ->
        deferred = do $q.defer
        resource.updateContacts id: id, params: params, (io) ->
          deferred.resolve io
          $rootScope.$broadcast 'updated_ios'
        deferred.promise

      @get = (io_id) ->
        deferred = $q.defer()
        resource.get id: io_id, (io) ->
          deferred.resolve(io)
        deferred.promise

      @delete = (deletedIO) ->
        deferred = $q.defer()
        resource.delete id: deletedIO.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_ios'
        deferred.promise

      return
  ]
