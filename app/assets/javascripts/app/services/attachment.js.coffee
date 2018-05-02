@service.service 'Attachment', ['$resource', ($resource) ->
    resource = $resource '/api/:entity/:id/attachments/:fileId', {id: '@id', entity: '@entity', fileId: '@fileId'},
        update:
            method: 'PUT'

    this.get = (params) -> resource.query(params).$promise
    this.save = (params) -> resource.save(params).$promise
    this.update = (params) -> resource.update(params).$promise
    this.delete = (params) -> resource.delete(params).$promise
    return
]