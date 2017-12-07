@app.controller 'PablisherController',
  ['$scope', '$routeParams', 'PublisherDetails', '$modal', ($scope, $routeParams, PublisherDetails, $modal) ->

    $scope.init = ->
      PublisherDetails.getPublisher(id: $routeParams.id).then (publisher) ->
        $scope.currentPublisher = publisher
        console.log $scope.currentPublisher

      PublisherDetails.associations(id: $routeParams.id).then (association) ->
        console.log association
        $scope.contacts = association.contacts
        $scope.publisherMembers = association.members

    $scope.showEditModal = (publisher) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_form.html'
        size: 'md'
        controller: 'PablisherEditController'
        backdrop: 'static'
        keyboard: false
        resolve:
          publisher: ->
            angular.copy publisher


      console.log(publisher)

    $scope.init()
]