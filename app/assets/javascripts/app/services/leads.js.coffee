@service.service 'Leads', [
    '$resource', '$q',
    ($resource,   $q) ->

        resource = $resource 'api/leads', {},
            get:
                method: 'GET'
                isArray: true
            users:
                url: '/api/leads/users'
                isArray: true
            accept:
                url: '/api/leads/:id/accept'
            reject:
                url: '/api/leads/:id/reject'
            reassign:
                url: '/api/leads/:id/reassign'


        this.get = (params) -> resource.get(params).$promise
        this.users = (params) -> resource.users(params).$promise
        this.accept = (params) -> resource.accept(params).$promise
        this.reject = (params) -> resource.reject(params).$promise
        this.reassign = (params) -> resource.reassign(params).$promise

        return
]
