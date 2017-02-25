@service.service 'IntegrationLogs',
  ['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->

      resource = $resource '/api/integration_logs/:id', { id: '@id' },
        getAll: {
          method: 'GET'
#          url: '/api/integration_logs'
          url: '/assets/icons/data.json'
        }
        send: {
          method: 'POST'
          url: '/api/integration_logs/:id/resend_request'
        }

      @$resource = resource

      @resend = (log) ->
        deferred = $q.defer()
        resource.send id: log.id, () ->
          deferred.resolve()
        deferred.promise

      @all = () ->
        deferred = $q.defer()
        resource.getAll (data) ->
          if data && data.integration_logs
            deferred.resolve(data.integration_logs)
        deferred.promise

      @get = (logId) ->
        deferred = $q.defer()
        resource.get id: logId, (log) ->
          deferred.resolve(log)
        deferred.promise

      return
  ]
