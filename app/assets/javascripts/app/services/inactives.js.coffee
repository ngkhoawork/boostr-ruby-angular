@service.service 'InactivesService',
    ['$resource',
        ($resource) ->

            resource = $resource '/api/inactives', { },
                update: {
                    method: 'PUT'
                    url: '/api'
                }

            resource
    ]