@app.controller 'ContactsController',
['$scope', '$rootScope', '$modal', '$routeParams', 'Contact',
($scope, $rootScope, $modal, $routeParams, Contact) ->

  $scope.init = ->
    Contact.all (contacts) ->
      $scope.contacts = contacts
      Contact.set($routeParams.id || contacts[0].id)

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false

  $scope.showEditModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsEditController'
      backdrop: 'static'
      keyboard: false

  $scope.$on 'updated_current_contact', ->
    $scope.currentContact = Contact.get()

  $scope.$on 'updated_contacts', ->
    $scope.init()

  $scope.init()
]
