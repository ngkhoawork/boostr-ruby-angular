@service.service 'WhereToPitchService',
    ['$resource',
        ($resource) ->

            resource = $resource '/api/where_to_pitch', { },
                update: {
                    method: 'PUT'
                    url: '/api'
                }

            resource
    ]