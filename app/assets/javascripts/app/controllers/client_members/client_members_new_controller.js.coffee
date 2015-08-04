@app.controller "ClientMembersNewController",
['$scope', 'ClientMember', 'Client', 'User', '$modalInstance'
($scope, ClientMember, Client, User, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"

  $scope.client_member = { client_id: Client.get().id }

  User.all().then (users) ->
    $scope.users = users

  $scope.roles = ClientMember.roles()

  $scope.submitForm = () ->
    ClientMember.create(client_id: $scope.client_member.client_id, client_member: $scope.client_member).then (client_member) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
