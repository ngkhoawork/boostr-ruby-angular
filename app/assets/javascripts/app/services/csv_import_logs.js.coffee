@service.service 'CsvImportLogs',
  ['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->

      resource = $resource '/api/csv_import_logs/:id', { id: '@id' },
        getAll: {
          method: 'GET'
          url: '/api/integration_logs'
        }

      @$resource = resource

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (data) ->
          deferred.resolve(data)
        deferred.promise

      return
  ]