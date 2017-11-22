@service.service 'DisplayLineItem',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        original.displayLineItem.values_attributes = original.displayLineItem.values
        angular.toJson(original)

      transformAddContactRequest = (original, headers) ->
        # original.displayLineItem.values_attributes = original.displayLineItem.values
        console.log 'original:', original
        angular.toJson(original.params)

      resource = $resource '/api/display_line_items/:id', { id: '@id' },
        get:
          isArray: true

        update:
          method: 'PUT'
          url: '/api/display_line_items/:id'
          transformRequest: transformRequest

        add_budget:
          method: 'POST'
          url: '/api/display_line_items/:id/add_budget'

        update_budget:
          method: 'PUT'
          url: '/api/display_line_item_budgets/:id'

        delete_budget:
          method: 'DELETE'
          url: 'api/display_line_item_budgets/:id'

      currentTempIO = undefined

      @query = resource.query

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (displayLineItems) ->
          deferred.resolve(displayLineItems)
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update params, (displayLineItem) ->
          deferred.resolve(displayLineItem)
          $rootScope.$broadcast 'updated_display_line_items'
        deferred.promise

      @add_budget = (params) ->
        deferred = $q.defer()
        resource.add_budget params,
          (resp) -> deferred.resolve(resp)
          (err) -> deferred.reject(err)
        deferred.promise

      @update_budget = (params) ->
        deferred = $q.defer()
        resource.update_budget params,
          (resp) -> deferred.resolve(resp)
          (err) -> deferred.reject(err)
        deferred.promise

      @delete_budget = (params) ->
        deferred = $q.defer()
        resource.delete_budget params,
          (resp) -> deferred.resolve(resp)
          (err) -> deferred.reject(err)
        deferred.promise

      @get = (display_line_item_id) ->
        deferred = $q.defer()
        resource.get id: display_line_item_id, (displayLineItem) ->
          deferred.resolve(displayLineItem)
        deferred.promise

      return
  ]
