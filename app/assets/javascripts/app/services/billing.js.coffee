@service.service 'Billing',
    ['$resource', '$q',
        ($resource, $q) ->

            resource = $resource '/api/billing_summary', {id: '@id'},
                updateDisplayLine:
                    method: 'PUT'
                    url: 'api/billing_summary/:id/update_display_line_item_budget_billing_status'
                updateContentFee:
                    method: 'PUT'
                    url: 'api/billing_summary/:id/update_content_fee_product_budget'

            @updateApproval = (data) ->
                deferred = $q.defer()
                console.log data
                switch data.revenue_type
                    when 'Display'
                        resource.updateDisplayLine {id: data.id, display_line_item_budget: data},
                            (resp) -> deferred.resolve(resp)
                            (resp) -> deferred.reject(resp)

                    when 'Content-Fee'
                        resource.updateContentFee {id: data.id, content_fee_product_budget: data},
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