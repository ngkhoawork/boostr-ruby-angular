@app.controller 'SettingsEgnyteController',
  ['$scope', '$modal', 'Egnyte', '$window', ( $scope,   $modal, Egnyte, $window) ->
    $scope.egnyte = {}
    $scope.currentEgnyteUser = {}

    $scope.submitForm = ->
      Egnyte.index().then (response) ->
        $window.location.href = response.egnyteTokenUrl

      $scope.errors = {}
      fields = ['domain', 'clientId']

      fields.forEach (key) ->
        field = $scope.egnyte[key]

        switch key
          when 'domain'
            if !field then return $scope.errors[key] = 'Domain is required'

          when 'clientId'
            if !field then return $scope.errors[key] = 'Client Id is required'

      if Object.keys($scope.errors).length > 0 then return
]