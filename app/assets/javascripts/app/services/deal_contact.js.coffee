@service.service 'DealContact',
['$resource', '$q',
($resource, $q) ->

  resource = $resource 'api/deals/:deal_id/deal_contacts/:id', { deal_id: '@deal_id', id: '@id' },
    update:
      method: 'PUT'
    delete:
      method: 'DELETE'

  return resource
]
