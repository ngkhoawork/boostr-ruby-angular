@service.service 'Seller',
  ['$resource', '$q'
    ($resource, $q) ->

      resource = $resource '/api/teams/:id/all_sales_reps', { id: '@id' }
      return resource
  ]