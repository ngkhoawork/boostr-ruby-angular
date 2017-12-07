@app.controller 'PablisherController',
  ['$scope', '$routeParams', 'PublisherDetails', ($scope, $routeParams, PublisherDetails) ->

    $scope.init = ->
      PublisherDetails.getPublisher(id: $routeParams.id).then (publisher) ->
        $scope.currentPublisher = publisher
        console.log $scope.currentPublisher

      PublisherDetails.associations(id: $routeParams.id).then (association) ->
        console.log association
        $scope.contacts = association.contacts
        $scope.publisherMembers = association.members

    $scope.init()
]