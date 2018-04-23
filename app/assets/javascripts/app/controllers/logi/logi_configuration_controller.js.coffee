@app.controller 'LogiConfigurationsController',
  ['$scope', '$rootScope', 'Logi', '$window', '$sce', '$http', ( $scope,   $rootScope, Logi, $window, $sce, $http) ->

    Logi.logiCallback().then (response) ->
      domain = response.data.domain + response.data.env
      secure_key_url = response.data.secure_key_url
      params = response.data.request_param
      main_url = domain + secure_key_url + params

      $http.post(main_url).success (key) ->
        $scope.logiUrl = $sce.trustAsResourceUrl(domain + "/rdPage.aspx?rdSecureKey=" + key)
        return

]