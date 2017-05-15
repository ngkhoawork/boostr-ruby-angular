@service.service 'PacingDashboard',
    ['$resource'
    ( $resource ) ->

            resource = $resource '/api/pacing_dashboard', null,
                pipeline_revenue:
                    method: 'GET'
                    url: '/api/pacing_dashboard/pipeline_and_revenue'

            @pipeline_revenue = (params) -> resource.pipeline_revenue(params).$promise

            return

    ]
