@service.service 'Egnyte',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/egnyte_integration', {id: '@id'},
      show:
        method: 'GET'
        url: '/api/egnyte_integration'
      egnyte_setup:
        method: 'GET'
        url: '/api/egnyte_integration/oauth_settings'
      update_settings:
        method: 'PUT'
        url: '/api/egnyte_integration'
      disconnect_egnyte:
        method: 'PUT'
        url: '/api/egnyte_integration/disconnect_egnyte'
      navigateToDeal:
        method: 'GET'
        url: '/api/egnyte_integration/navigate_to_deal'
      navigateToAccount:
        method: 'GET'
        url: '/api/egnyte_integration/navigate_to_account_deals'


    this.show = (params) -> resource.show(params).$promise
    this.egnyteSetup = (params) -> resource.egnyte_setup(params).$promise
    this.updateConfiguration = (params) -> resource.update_settings(params).$promise
    this.disconnect = (params) -> resource.disconnect_egnyte(params).$promise
    this.navigateToDeal = (params) -> resource.navigateToDeal(params).$promise
    this.navigateToAccount = (params) -> resource.navigateToAccount(params).$promise

    return
  ]