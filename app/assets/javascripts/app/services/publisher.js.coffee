@service.service 'Publisher',
  ['$resource', '$rootScope', '$q', '$location', ( $resource, $rootScope, $q, $location ) ->
    resource = $resource '/api/publishers', {id: '@id'},
      publishersList:
        method: 'GET'
        url: '/api/publishers'
        isArray: true
      publishersPipeline:
        method: 'GET'
        url: '/api/publishers/pipeline'
        isArray: true
      pipelineHeaders:
        method: 'GET'
        url: '/api/publishers/pipeline_headers'
        isArray: true
      publisherSettings:
        method: 'GET'
        url: '/api/publishers/settings'
      create:
        method: 'POST'
        url: '/api/publishers'
      update:
        method: 'PUT'
        url: '/api/publishers/:id'
      delete:
        method: 'DELETE'
        url: '/api/publishers/:id'
      publisherReport:
        method: 'GET'
        url: '/api/publishers/all_fields_report'
        isArray: true

    this.publishersList = (params) -> resource.publishersList(params).$promise
    this.publishersPipeline = (params) -> resource.publishersPipeline(params).$promise
    this.pipelineHeaders = (params) -> resource.pipelineHeaders(params).$promise
    this.publisherSettings = (params) -> resource.publisherSettings(params).$promise
    this.publisherReport = (params) -> resource.publisherReport(params).$promise
    this.create = (params) -> resource.create(params).$promise

    this.delete = (params) ->
      deferred = $q.defer()
      resource.delete params,
        (resp) ->
          deferred.resolve(resp)
          $location.url("/publishers")
        (err) ->
          deferred.reject(err)
      deferred.promise

    this.update = (params) ->
      deferred = $q.defer()
      resource.update params,
        (resp) ->
          deferred.resolve(resp)
          $rootScope.$broadcast 'updated_publishers', resp
        (err) ->
          deferred.reject(err)
      deferred.promise

    return
  ]