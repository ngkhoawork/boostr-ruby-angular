@service.service 'PublisherCustomFieldName',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        original.publisher_custom_field_name.values_attributes = original.publisher_custom_field_name.values
        original.publisher_custom_field_name.contact_cf_options_attributes = original.publisher_custom_field_name.customFieldOptions
        angular.toJson(original)

      resource = $resource '/api/publisher_custom_field_names/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/publisher_custom_field_names'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/publisher_custom_field_names/:id'
          transformRequest: transformRequest

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
        resource.query params, (data) ->
          deferred.resolve(data)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (data) ->
            deferred.resolve(data)
            $rootScope.$broadcast 'updated_publisher_custom_field_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (data) ->
            deferred.resolve(data)
            $rootScope.$broadcast 'updated_publisher_custom_field_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @delete = (params) ->
        deferred = $q.defer()
        resource.delete params, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_publisher_custom_field_names'
        deferred.promise

      return
  ]
