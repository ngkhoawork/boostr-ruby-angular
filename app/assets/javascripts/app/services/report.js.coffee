@service.service 'Report',
    ['$resource', '$q',
    ( $resource,   $q ) ->

            resource = $resource 'api/reports', {},
                split_adjusted:
                    method: 'GET'
                    url: '/api/reports/split_adjusted'
                    isArray: true

            return resource
    ]
