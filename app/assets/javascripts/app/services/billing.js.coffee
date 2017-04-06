@service.service 'Billing',
    ['$resource', '$q',
        ($resource, $q) ->

            resource = $resource '/api/billing_summary', {id: '@id'},
                updateDisplayLineStatus:
                    method: 'PUT'
                    url: 'api/billing_summary/:id/update_display_line_item_budget_billing_status'
                updateDisplayLineQuantity:
                    method: 'PUT'
                    url: 'api/billing_summary/:id/update_quantity'
                updateContentFee:
                    method: 'PUT'
                    url: 'api/billing_summary/:id/update_content_fee_product_budget'

            @updateStatus = (data) ->
                deferred = $q.defer()
                switch data.revenue_type
                    when 'Display'
                        resource.updateDisplayLineStatus {
                                id: data.id
                                display_line_item_budget:
                                    billing_status: data.billing_status
                            },
                            (resp) -> deferred.resolve(resp)
                            (resp) -> deferred.reject(resp)

                    when 'Content-Fee'
                        resource.updateContentFee {
                                id: data.id
                                content_fee_product_budget:
                                    billing_status: data.billing_status
                            },
                            (resp) -> deferred.resolve(resp)
                            (resp) -> deferred.reject(resp)
                deferred.promise

            @updateBudget = (data) ->
                deferred = $q.defer()
                resource.updateContentFee {
                        id: data.id
                        content_fee_product_budget:
                            budget_loc: data.amount
                    },
                    (resp) -> deferred.resolve(resp)
                    (resp) -> deferred.reject(resp)
                deferred.promise

            @updateQuantity = (data) ->
                deferred = $q.defer()
                resource.updateDisplayLineQuantity {
                        id: data.id
                        display_line_item_budget:
                            quantity: data.quantity
                    },
                    (resp) -> deferred.resolve(resp)
                    (resp) -> deferred.reject(resp)
                deferred.promise

            @all = (filter) ->
                deferred = $q.defer()
                resource.get filter, (data) ->
                    deferred.resolve(data)
                deferred.promise

            return
    ]
