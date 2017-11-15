@service.service 'ReportQuery',
['$resource', '$rootScope', '$q', ($resource, $rootScope, $q) ->

	resource = $resource '/api/filter_queries/:id', {id: '@id'},
		get:
			method: 'GET'
			isArray: true
		save:
			method: 'POST'
		update:
			method: 'PUT'
		delete:
			method: 'DELETE'

	@get = (params) -> resource.get(params).$promise
	@save = (params) ->
		deferred = $q.defer()
		resource.save params,
			(resp) ->
				deferred.resolve(resp)
				$rootScope.$broadcast 'report_queries_updated'
		deferred.promise

	@update = (params) ->
		deferred = $q.defer()
		resource.update params,
			(resp) ->
				deferred.resolve(resp)
				$rootScope.$broadcast 'report_queries_updated'
		deferred.promise

	@delete = (params) ->
		deferred = $q.defer()
		resource.delete params,
			(resp) ->
				deferred.resolve(resp)
				$rootScope.$broadcast 'report_queries_updated'
		deferred.promise


	return
]
