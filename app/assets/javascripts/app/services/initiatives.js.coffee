@service.service 'Initiatives',
['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->
        resource = $resource '/api/initiatives/:id', {id: '@id'},
            get:
                url: '/api/initiatives'
                method: 'GET'
                isArray: true

            update:
                method: 'PUT'

        @all = () ->
            deferred = $q.defer()
            resource.get null, (data) ->
                deferred.resolve(data)
            deferred.promise

        @create = (initiative) ->
            deferred = $q.defer()
            resource.save initiative, (data) ->
                deferred.resolve(data)
                $rootScope.$broadcast 'initiatives_updated'
            deferred.promise

        @update = (initiative) ->
            deferred = $q.defer()
            resource.update id: initiative.id, initiative, (data) ->
                deferred.resolve(data)
                $rootScope.$broadcast 'initiatives_updated'
            deferred.promise

        @delete = (initiative) ->
            deferred = $q.defer()
            resource.delete id: initiative.id, () ->
                deferred.resolve()
                $rootScope.$broadcast 'initiatives_updated'
            deferred.promise

        return
]
