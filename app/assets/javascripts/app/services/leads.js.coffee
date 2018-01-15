@service.service 'Leads',
    ['$resource', '$q',
        ( $resource,   $q ) ->

            resource = $resource 'api/leads', {},
                get:
                    method: 'GET'
                    isArray: true

            this.get = (params) -> resource.get(params).$promise

            return
    ]
