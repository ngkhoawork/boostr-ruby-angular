@service.service 'TimeDimension',
	['$resource', '$q',
	( $resource,   $q) ->
		resource = $resource '/api/time_dimensions'

		@all = -> resource.query().$promise

		return
]
