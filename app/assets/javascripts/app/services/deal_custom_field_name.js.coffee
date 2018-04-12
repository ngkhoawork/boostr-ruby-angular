@service.service 'DealCustomFieldName',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        console.log(original)
        original.deal_custom_field_name.values_attributes = original.deal_custom_field_name.values
        original.deal_custom_field_name.deal_custom_field_options_attributes = original.deal_custom_field_name.customFieldOptions
        angular.toJson(original)

      transformAddContactRequest = (original, headers) ->
        # original.deal_custom_field_name.values_attributes = original.deal_custom_field_name.values
        console.log 'original:', original
        angular.toJson(original.params)

      resource = $resource '/api/deal_custom_field_names/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/deal_custom_field_names'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/deal_custom_field_names/:id'
          transformRequest: transformRequest
        csv_headers:
          method: 'GET'
          url: '/api/deal_custom_field_names/csv_headers'
          isArray: true

      currentDealCustomFieldName = undefined

      @field_type_list = [
        { name: 'Currency', value: 'currency' }
        { name: 'Text', value: 'text' }
        { name: 'Notes', value: 'note' }
        { name: 'Date/Time', value: 'datetime' }
        { name: 'Number', value: 'number' }
        { name: 'Number - 4 decimal', value: 'number_4_dec' }
        { name: 'Integer', value: 'integer' }
        { name: 'Boolean', value: 'boolean' }
        { name: 'Percentage', value: 'percentage' }
        { name: 'Dropdown', value: 'dropdown' }
        { name: 'Sum', value: 'sum' }
        { name: 'Link', value: 'link' }
      ]

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (deal_custom_field_names) ->
          deferred.resolve(deal_custom_field_names)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (deal_custom_field_name) ->
            deferred.resolve(deal_custom_field_name)
            $rootScope.$broadcast 'updated_deal_custom_field_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (deal_custom_field_name) ->
            deferred.resolve(deal_custom_field_name)
            $rootScope.$broadcast 'updated_deal_custom_field_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @get = (deal_custom_field_name_id) ->
        deferred = $q.defer()
        resource.get id: deal_custom_field_name_id, (deal_custom_field_name) ->
          deferred.resolve(deal_custom_field_name)
        deferred.promise

      @delete = (deletedDealCustomFieldName) ->
        deferred = $q.defer()
        resource.delete id: deletedDealCustomFieldName.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_deal_custom_field_names'
        deferred.promise

      @csv_headers = (params) -> resource.csv_headers(params).$promise

      return
  ]
