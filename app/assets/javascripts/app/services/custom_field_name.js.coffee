@service.service 'CustomFieldNames',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        original.custom_field_name.custom_field_options_attributes = original.custom_field_name.customFieldOptions
        angular.toJson(original)

      resource = $resource '/api/custom_field_names/', {id: '@id'},
        save:
          method: 'POST'
          url: '/api/custom_field_names'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/custom_field_names/:id'
          transformRequest: transformRequest
        all:
          method: 'GET'
          url: '/api/custom_field_names'
          isArray: true
        delete:
          method: 'DELETE'
          url: '/api/custom_field_names/:id'


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

      this.all = (params) -> resource.all(params).$promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (data) ->
            deferred.resolve(data)
            $rootScope.$broadcast 'updated_custom_field_names'
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
            $rootScope.$broadcast 'updated_custom_field_names'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @delete = (params) ->
        deferred = $q.defer()
        resource.delete params, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_custom_field_names'
        deferred.promise

      return
  ]
