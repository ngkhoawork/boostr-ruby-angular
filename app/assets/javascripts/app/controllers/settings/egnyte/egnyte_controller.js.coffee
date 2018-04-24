@app.controller 'SettingsEgnyteController',
  ['$scope', 'Egnyte', ( $scope, Egnyte) ->
    $scope.egnyte = {}

    Egnyte.show().then (egnyteSettings) ->
      $scope.egnyteEnabled = egnyteSettings.enabled
]