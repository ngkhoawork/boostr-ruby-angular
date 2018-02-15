@service.service 'Product',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.product.values_attributes = original.product.values
    original.product.parent_id = null if original.product.parent_id == undefined
    angular.toJson(original)

  resource = $resource '/api/products/:id', { id: '@id', product_id: '@product_id' },
    save: {
      method: 'POST'
      url: '/api/products'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/products/:id'
      transformRequest: transformRequest
    }
    get_units: {
      method: 'GET'
      url: '/api/products/:product_id/ad_units'
      isArray: true
    }
    add_unit: {
      method: 'POST'
      url: '/api/products/:product_id/ad_units'
    }
    update_unit: {
      method: 'PUT'
      url: '/api/products/:product_id/ad_units/:id'
    }
    delete_unit: {
      method: 'DELETE'
      url: '/api/products/:product_id/ad_units/:id'
    }

  allProducts = []
  currentProduct = undefined

  @get_units = (params) ->
    deferred = $q.defer()
    resource.get_units params,
      (resp) ->
        deferred.resolve(resp)
    deferred.promise

  @add_unit = (params) ->
    deferred = $q.defer()
    resource.add_unit params,
      (resp) ->
        deferred.resolve(resp)
        $rootScope.$broadcast 'updated_product_units', params.product_id
    deferred.promise

  @update_unit = (params) ->
    deferred = $q.defer()
    resource.update_unit params,
      (resp) ->
        deferred.resolve(resp)
        $rootScope.$broadcast 'updated_product_units', params.product_id
    deferred.promise

  @delete_unit = (params) ->
    deferred = $q.defer()
    resource.delete_unit params,
      (resp) ->
        deferred.resolve(resp)
        $rootScope.$broadcast 'updated_product_units', params.product_id
    deferred.promise

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (products) ->
      allProducts = products
      deferred.resolve(products)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (product) ->
      deferred.resolve(product)
      $rootScope.$broadcast 'updated_products'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (product) ->
      deferred.resolve(product)
      $rootScope.$broadcast 'updated_products'
    deferred.promise

  @get = () ->
    currentProduct

  @set = (product_id) =>
    currentProduct = _.find allProducts, (product) ->
      return parseInt(product_id) == product.id
    $rootScope.$broadcast 'updated_current_product'

  return
]
