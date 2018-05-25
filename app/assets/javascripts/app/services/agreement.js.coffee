@service.service 'Agreement',
['$resource'
($resource) ->
	$resource 'api/spend_agreements', { id: '@id' },
	add:
		method: 'POST'
		url: '/api/spend_agreements'
	get:
		method: 'GET'
		url: '/api/spend_agreements/:id'
	update:
		method: 'PUT'
		url: '/api/spend_agreements/:id'
	delete:
		method: 'DELETE'
		url: '/api/spend_agreements/:id'

	get_deals:
		method: 'GET'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_deals'
		isArray: true
	get_available_deals:
		method: 'GET'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_deals/available_to_match'
		isArray: true
	exclude_deal:
		method: 'DELETE'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_deals/:id'

	get_ios:
		method: 'GET'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_ios'
		isArray: true
	exclude_io:
		method: 'DELETE'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_ios/:id'

	get_members:
		method: 'GET'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_team_members'
		isArray: true
	update_member:
		method: 'PUT'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_team_members/:id'
	exclude_member:
		method: 'DELETE'
		url: '/api/spend_agreements/:spend_agreement_id/spend_agreement_team_members/:id'

	get_deal_agreements:
		method: 'GET'
		url: '/api/deals/:deal_id/spend_agreements'
		isArray: true
	get_available_agreements:
		method: 'GET'
		url: '/api/deals/:id/possible_agreements'
		isArray: true
	assign_agreements:
		method: 'PUT'	
		url: '/api/deals/:deal_id/assign_agreements'

	get_io_agreements:
		method: 'GET'
		url: '/api/ios/:io_id/spend_agreements'
		isArray: true
]