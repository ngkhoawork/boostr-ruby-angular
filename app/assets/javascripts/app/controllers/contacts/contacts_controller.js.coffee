@app.controller 'ContactsController',
['$scope', '$modal', 'Contact',
($scope, $modal, Contact) ->

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false

]
