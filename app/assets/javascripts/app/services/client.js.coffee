@service.service 'Client', ['$resource', ($resource) ->

  $resource '/clients/:id', { id: '@id' }

]