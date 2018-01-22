@service.service 'Egnyte',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/egnyte_integration', {id: '@id'},
      show:
        method: 'GET'
        url: '/api/egnyte_integration'
      egnyte_setup:
        method: 'GET'
        url: '/api/egnyte_integration/oauth_settings'
      save_token:
        method: 'PUT'
        url: '/api/egnyte_integration'
      disconnect_egnyte:
        method: 'GET'
        url: '/api/egnyte_integration/disconnect_egnyte'

    this.show = (params) -> resource.show(params).$promise
    this.egnyteSetup = (params) -> resource.egnyte_setup(params).$promise
    this.updateConfiguration = (params) -> resource.save_token(params).$promise
    this.disconnect = (params) -> resource.disconnect_egnyte(params).$promise

    return
  ]