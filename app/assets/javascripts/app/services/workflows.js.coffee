@service.service 'Workflows',
  ['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->

      transformRequest = (original, headers) ->
        original.workflow.workflow_action_attributes = original.workflow.workflow_action
        original.workflow.workflow_criterions_attributes = original.workflow.workflow_criterions

        angular.toJson(original)

      resource = $resource '/api/workflows/:id', {id: '@id'},
        save: {
          method: 'POST'
          url: '/api/workflows/'
          transformRequest: transformRequest
        },
        update: {
          method: 'PUT'
          url: '/api/workflows/:id'
          transformRequest: transformRequest
        }

      @all = ->
        resource.query().$promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save workflow: params, (data) ->
          deferred.resolve(data)
          $rootScope.$broadcast 'workflows_updated'
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update {id: params.id, workflow: params}, (data) ->
          deferred.resolve(data)
          $rootScope.$broadcast 'workflows_updated'
        deferred.promise

      @delete = (params) ->
        deferred = $q.defer()
        resource.delete id: params.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'workflows_updated'
        deferred.promise

      return
  ]
