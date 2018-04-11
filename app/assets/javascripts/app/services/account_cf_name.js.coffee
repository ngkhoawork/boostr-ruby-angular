@service.service 'AccountCfName',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        original.account_cf_name.values_attributes = original.account_cf_name.values
        original.account_cf_name.account_cf_options_attributes = original.account_cf_name.customFieldOptions
        angular.toJson(original)

      transformAddContactRequest = (original, headers) ->
        # original.account_cf_name.values_attributes = original.account_cf_name.values
        console.log 'original:', original
        angular.toJson(original.params)

      resource = $resource '/api/account_cf_names/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/account_cf_names'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/account_cf_names/:id'
          transformRequest: transformRequest
        csv_headers:
          method: 'GET'
          url: '/api/account_cf_names/csv_headers'
          isArray: true

      currentAccountCfName = undefined

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
      ]

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (account_cf_names) ->
          deferred.resolve(account_cf_names)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (account_cf_name) ->
            deferred.resolve(account_cf_name)
            $rootScope.$broadcast 'updated_account_cf_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (account_cf_name) ->
            deferred.resolve(account_cf_name)
            $rootScope.$broadcast 'updated_account_cf_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @get = (account_cf_name_id) ->
        deferred = $q.defer()
        resource.get id: account_cf_name_id, (account_cf_name) ->
          deferred.resolve(account_cf_name)
        deferred.promise

      @delete = (deletedAccountCfName) ->
        deferred = $q.defer()
        resource.delete id: deletedAccountCfName.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_account_cf_names'
        deferred.promise

      @csv_headers = (params) -> resource.csv_headers(params).$promise

      return
  ]
