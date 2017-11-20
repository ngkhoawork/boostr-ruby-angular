@service.service 'PMPMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.pmp_member.values_attributes = original.pmp_member.values
    angular.toJson(original)

  resource = $resource '/api/pmps/:pmp_id/pmp_members/:id', { pmp_id: '@pmp_id', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/pmps/:pmp_id/pmp_members'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/pmps/:pmp_id/pmp_members/:id'
      transformRequest: transformRequest
    }

  @all = (params) ->
    resource.query params, (pmp_member) ->
      deferred = $q.defer()
      deferred.resolve(pmp_member)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (pmp_member) ->
      deferred.resolve(pmp_member)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (pmp_member) ->
      deferred.resolve(pmp_member)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { pmp_id: params.pmp_id, id: params.id }, (pmp) ->
      deferred.resolve(pmp)
    deferred.promise

  return
]
