@service.service 'WorkflowCriterions',
  ['$resource', '$q',
    ($resource, $q) ->
      resource = $resource '/api/workflows/:workflow_id/workflow_criterions/:id', {id: '@id'}

      @delete = (params) ->
        deferred = $q.defer()
        resource.delete (id: params.id, workflow_id: params.workflow_id), () ->
          deferred.resolve()
        deferred.promise

      return
  ]
