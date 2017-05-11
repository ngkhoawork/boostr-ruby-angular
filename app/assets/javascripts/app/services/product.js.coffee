@service.service 'Product',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.product.values_attributes = original.product.values
    angular.toJson(original)

  resource = $resource '/api/products/:id', { id: '@id' },
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

  allProducts = []
  currentProduct = undefined

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
