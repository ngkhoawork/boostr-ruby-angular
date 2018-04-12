@service.service 'DealProductCfName',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        console.log(original)
        original.deal_product_cf_name.values_attributes = original.deal_product_cf_name.values
        original.deal_product_cf_name.deal_product_cf_options_attributes = original.deal_product_cf_name.customFieldOptions
        angular.toJson(original)

      transformAddContactRequest = (original, headers) ->
        # original.deal_product_cf_name.values_attributes = original.deal_product_cf_name.values
        console.log 'original:', original
        angular.toJson(original.params)

      resource = $resource '/api/deal_product_cf_names/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/deal_product_cf_names'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/deal_product_cf_names/:id'
          transformRequest: transformRequest
        csv_headers:
          method: 'GET'
          url: '/api/deal_product_cf_names/csv_headers'
          isArray: true

      currentDealProductCfName = undefined

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
      ]

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (deal_product_cf_names) ->
          deferred.resolve(deal_product_cf_names)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (deal_product_cf_name) ->
            deferred.resolve(deal_product_cf_name)
            $rootScope.$broadcast 'updated_deal_product_cf_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (deal_product_cf_name) ->
            deferred.resolve(deal_product_cf_name)
            $rootScope.$broadcast 'updated_deal_product_cf_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @get = (deal_product_cf_name_id) ->
        deferred = $q.defer()
        resource.get id: deal_product_cf_name_id, (deal_product_cf_name) ->
          deferred.resolve(deal_product_cf_name)
        deferred.promise

      @delete = (deletedDealProductCfName) ->
        deferred = $q.defer()
        resource.delete id: deletedDealProductCfName.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_deal_product_cf_names'
        deferred.promise

      @csv_headers = (params) -> resource.csv_headers(params).$promise

      return
  ]
