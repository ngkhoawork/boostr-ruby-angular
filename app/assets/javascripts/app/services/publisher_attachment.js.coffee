@service.service 'PublisherAttachment',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publishers', {publisher_id: '@id'},
      list:
        method: 'GET'
        url: ' /api/publishers/:publisher_id/attachments'
        isArray: true

    this.list = (params) -> resource.list(params).$promise

    return
  ]