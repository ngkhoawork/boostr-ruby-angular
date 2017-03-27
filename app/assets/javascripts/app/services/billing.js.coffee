@service.service 'Billing',
    ['$resource', '$q',
        ($resource, $q) ->

            resource = $resource '/api/billing_summary', {}

            @all = (filter) ->
                deferred = $q.defer()
                resource.get filter, (data) ->
                    deferred.resolve(data)
                deferred.promise

            return
    ]