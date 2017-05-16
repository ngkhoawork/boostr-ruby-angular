@service.service 'PacingDashboard',
    ['$resource'
    ( $resource ) ->

            resource = $resource '/api/pacing_dashboard', null,
                pipeline_revenue:
                    method: 'GET'
                    url: '/api/pacing_dashboard/pipeline_and_revenue'
                activity_pacing:
                    method: 'GET'
                    url: '/api/pacing_dashboard/activity_pacing'

            @pipeline_revenue = (params) -> resource.pipeline_revenue(params).$promise
            @activity_pacing = (params) -> resource.activity_pacing(params).$promise

            return
    ]
