@service.service 'ProductFamily',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/product_families/:id', { id: '@id', product_family_id: '@product_family_id' },
    save: {
      method: 'POST'
      url: '/api/product_families'
    },
    update: {
      method: 'PUT'
      url: '/api/product_families/:id'
    }
    delete: {
      method: 'DELETE'
      url: '/api/product_families/:id'
    }

  allProductFamilies = []
  currentProductFamily = undefined

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (product_families) ->
      allProductFamilies = product_families
      deferred.resolve(product_families)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (product_family) ->
      deferred.resolve(product_family)
      $rootScope.$broadcast 'updated_product_families'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (product_family) ->
      deferred.resolve(product_family)
      $rootScope.$broadcast 'updated_product_families'
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_product_families'
    deferred.promise

  @get = () ->
    currentProductFamily

  @set = (product_family_id) =>
    currentProductFamily = _.find allProductFamilies, (product_family) ->
      return parseInt(product_family_id) == product_family.id
    $rootScope.$broadcast 'updated_current_product_family'

  return
]
