@service.service 'InactivesService',
    ['$resource',
        ($resource) ->

            resource = $resource '/api/inactives', { },
                inactive: {
                    method: 'GET'
                    url: '/api/inactives/inactives'
                    isArray: true
                }
                seasonalInactive: {
                    method: 'GET'
                    url: '/api/inactives/seasonal_inactives'
                }

            resource
    ]