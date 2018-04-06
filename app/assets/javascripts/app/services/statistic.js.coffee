@service.service 'STATISTIC',
  ['$resource', '$q', '$rootScope',
    ($resource, $q) ->

      resource = $resource '/api/statistics/:id', { id: '@id' }

      @all = (id) ->
        deferred = $q.defer()
        resource.query id: id, (statistics) ->
          deferred.resolve(statistics)
        deferred.promise

      return
  ]
