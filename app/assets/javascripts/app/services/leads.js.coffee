@service.service 'Leads', [
    '$rootScope', '$resource', '$q',
    ($rootScope,  $resource,    $q) ->

        resource = $resource '/api/leads', {},
            get:
                isArray: true
            getById:
                url: '/api/leads/:id'
            update:
                method: 'PUT'
                url: '/api/leads/:id'
            users:
                url: '/api/leads/users'
                isArray: true
            accept:
                url: '/api/leads/:id/accept'
            reject:
                url: '/api/leads/:id/reject'
            reassign:
                url: '/api/leads/:id/reassign'
            mapAccount:
                url: '/api/leads/:id/map_with_client'


        this.get = (params) -> resource.get(params).$promise
        this.getById = (params) -> resource.getById(params).$promise
        this.update = (id, params) -> resource.update(id, params).$promise
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
        this.mapAccount = (params) ->
            deferred = $q.defer()
            resource.mapAccount params, (lead) ->
                deferred.resolve(lead)
                $rootScope.$broadcast 'updated_lead', lead
            , (error) ->
                deferred.reject(error)
            deferred.promise
        return
]
