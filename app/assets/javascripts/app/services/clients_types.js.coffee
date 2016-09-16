@service.service 'ClientsTypes',
  ['$resource', '$rootScope', '$q', 'Field',
    ($resource, $rootScope, $q, Field) ->
      return {
        list: () ->
          deferred = $q.defer()
          clientDefaultFieldsValues = {}
          client_types = {fieldId: 0, types: [] }
          Field.defaults(clientDefaultFieldsValues, 'Client')
          .then (fields) ->
            _.each fields, (field) ->
              if field.name == 'Client Type'
                client_types.fieldId = field.id;
                _.each field.options, (option) ->
                  client_types.types.push({typeId: option.id, name: option.name})
            deferred.resolve(client_types)
          , (err) ->
            deferred.reject(client_types)
          return deferred.promise
      }
  ]
