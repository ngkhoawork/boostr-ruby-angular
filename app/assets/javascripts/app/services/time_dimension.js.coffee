@service.service 'TimeDimension',
	['$resource', '$q',
	( $resource,   $q) ->
		resource = $resource '/api/time_dimensions', {},
      revenue_fact_dimension_months:
        method: 'GET'
        url: '/api/time_dimensions/revenue_fact_dimension_months'
        isArray: true

		@all = ->
      resource.query().$promise

    @revenue_fact_dimension_months = ->
      resource.revenue_fact_dimension_months().$promise

		return
]
