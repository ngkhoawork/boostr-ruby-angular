@service.service 'Product',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/products/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/products/:id'
    }

  allProducts = []
  currentProduct = undefined

  @all = ->
    deferred = $q.defer()
    resource.query {}, (products) ->
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
    deferred.promise

  @get = () ->
    currentProduct

  @set = (product_id) =>
    currentProduct = _.find allProducts, (product) ->
      return parseInt(product_id) == product.id
    $rootScope.$broadcast 'updated_current_product'

  @product_lines = () ->
    [
      'Desktop'
      'Phone'
      'Tablet'
    ]

  @families = () ->
    [
      'Video'
      'Native'
      'Banner'
    ]

  @pricing_types = () ->
    [
      'CPM'
      'CPC'
      'CPE'
    ]

  return
]
