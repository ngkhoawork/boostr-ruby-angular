@service.service 'Egnyte',
  ['$resource', ( $resource ) ->
    resource = $resource 'api/egnyte', {id: '@id'},
      index:
        method: 'GET'
        url: '/api/egnyte'
      save_token:
        method: 'GET'
        url: '/api/save_token'
      update_egnyte_settings:
        method: 'GET'
        url: '/api/update_egnyte_settings'


    this.index = (params) -> resource.index(params).$promise
    this.saveToken = (params) -> resource.save_token(params).$promise
    this.updateEgnyteSettings = (params) -> resource.update_egnyte_settings(params).$promise

    return
  ]