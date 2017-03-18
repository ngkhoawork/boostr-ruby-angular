@service.service 'Initiatives',
['$resource', '$rootScope', '$q',
    ($resource, $rootScope, $q) ->
        resource = $resource '/api/initiatives/:id', {id: '@id'},
            get:
                url: '/api/initiatives'
                method: 'GET'
                isArray: true
            getSummary:
                url: 'api/initiatives/smart_report'
                method: 'GET'
                isArray: true
            getDeals:
                url: 'api/initiatives/:id/smart_report_deals'
                method: 'GET'
            update:
                method: 'PUT'

        @all = (type) ->
            deferred = $q.defer()
            if type
                type = {closed: true} if type is 'closed'
                resource.getSummary type, (data) ->
                    deferred.resolve(data)
            else
                resource.get null, (data) ->
                    deferred.resolve(data)
            deferred.promise

        @deals = (initiativeId) ->
            deferred = $q.defer()
            resource.getDeals id: initiativeId, (data) ->
                deferred.resolve(data)
            deferred.promise

        @summaryClosed = ->
            deferred = $q.defer()
            resource.getSummary {closed: true}, (data) ->
                deferred.resolve(data)
            deferred.promise

        @create = (initiative) ->
            deferred = $q.defer()
            resource.save initiative: initiative, (data) ->
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
