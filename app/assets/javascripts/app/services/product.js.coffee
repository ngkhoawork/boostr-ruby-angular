@service.service 'Product',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  resource = $resource '/api/products/:id', { id: '@id' }

  @all = ->
    deferred = $q.defer()
    resource.query {}, (products) ->
      deferred.resolve(products)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (products) ->
      deferred.resolve(products)
      $rootScope.$broadcast 'updated_products'
    deferred.promise

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