@service.service 'Leads', [
    '$rootScope', '$resource', '$q',
    ($rootScope,  $resource,    $q) ->

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
        this.accept = (params) ->
            deferred = $q.defer()
            resource.accept params, (lead) ->
                deferred.resolve(lead)
                $rootScope.$broadcast 'updated_leads'
            , (error) ->
                deferred.reject(error)
            deferred.promise
        this.reject = (params) ->
            deferred = $q.defer()
            resource.reject params, (lead) ->
                deferred.resolve(lead)
                $rootScope.$broadcast 'updated_leads'
            , (error) ->
                deferred.reject(error)
            deferred.promise
        this.reassign = (params) ->
            deferred = $q.defer()
            resource.reassign params, (lead) ->
                deferred.resolve(lead)
                $rootScope.$broadcast 'updated_leads'
            , (error) ->
                deferred.reject(error)
            deferred.promise

        return
]
