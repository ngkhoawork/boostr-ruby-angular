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
            product_monthly_summary:
                method: 'GET'
                url: '/api/reports/product_monthly_summary'
                isArray: false
            quota_attainment:
                method: 'GET'
                url: '/api/reports/quota_attainment'
                isArray: true

        return resource
    ]
