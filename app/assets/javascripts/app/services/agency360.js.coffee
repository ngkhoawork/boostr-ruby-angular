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
				url: '/api/agency_dashboards/spend_by_advertisers'
				isArray: true
			spendByCategory:
				method: 'GET'
				url: '/api/agency_dashboards/spend_by_category'
				isArray: true
			winRateByCategory:
				method: 'GET'
				url: '/api/agency_dashboards/win_rate_by_category'
				isArray: true
			relatedContacts:
				method: 'GET'
				url: '/api/agency_dashboards/contacts_and_related_advertisers'
				isArray: true
			activityHistory:
				method: 'GET'
				url: '/api/agency_dashboards/activity_history'
				isArray: true
			advertisersWithoutSpend:
				method: 'GET'
				url: '/api/agency_dashboards/related_advertisers_without_spend'
				isArray: true


		this.spendByProduct = (params) -> resource.spendByProduct(params).$promise
		this.spendByAdvertiser = (params) -> resource.spendByAdvertiser(params).$promise
		this.spendByCategory = (params) -> resource.spendByCategory(params).$promise
		this.winRateByCategory = (params) -> resource.winRateByCategory(params).$promise
		this.relatedContacts = (params) -> resource.relatedContacts(params).$promise
		this.activityHistory = (params) -> resource.activityHistory(params).$promise
		this.advertisersWithoutSpend = (params) -> resource.advertisersWithoutSpend(params).$promise

		return
	]