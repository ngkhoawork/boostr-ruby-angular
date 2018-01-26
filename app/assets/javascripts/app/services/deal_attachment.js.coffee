@service.service 'DealAttachment',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/deals', {deal_id: '@id'},
      list:
        method: 'GET'
        url: ' /api/deals/:deal_id/attachments'
        isArray: true

    this.list = (params) -> resource.list(params).$promise

    return
  ]