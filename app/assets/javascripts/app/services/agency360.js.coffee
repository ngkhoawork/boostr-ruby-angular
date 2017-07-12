@service.service 'Agency360',
	['$resource'
	( $resource ) ->

		resource = $resource '/api/agency_dashboards/', {},
			spendByProduct:
				method: 'GET'
				url: '/api/agency_dashboards/spend_by_product'
				isArray: true
			spendByAdvertiser:
				method: 'GET'
				url: '/api/agency_dashboards/spend_by_advertiser'
				isArray: true

		@spendByProduct = (params) -> resource.spendByProduct(params).$promise

		return
	]