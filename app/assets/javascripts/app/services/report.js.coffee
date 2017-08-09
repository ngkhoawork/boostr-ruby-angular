@service.service 'Report',
    ['$resource', '$q',
    ( $resource,   $q ) ->

        resource = $resource 'api/reports', {},
            split_adjusted:
                method: 'GET'
                url: '/api/reports/split_adjusted'
                isArray: true
            pipeline_summary:
                method: 'GET'
                url: '/api/reports/pipeline_summary'
                isArray: true

        return resource
    ]
