@service.service 'Logi',
  ['$resource', '$rootScope', '$q', '$location', ( $resource, $rootScope, $q, $location ) ->
    resource = $resource '/api/logi_configurations', {id: '@id'},
      logiCallback:
        method: 'GET'
        url: '/api/logi_configurations/logi_callback'

    this.logiCallback = (params) -> resource.logiCallback(params).$promise

    return
  ]