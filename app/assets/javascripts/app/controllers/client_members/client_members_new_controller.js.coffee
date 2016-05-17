@app.controller "ClientMembersNewController",
['$scope', '$modalInstance', 'ClientMember', 'Client', 'User', 'Field',
($scope, $modalInstance, ClientMember, Client, User, Field) ->

  $scope.formType = "New"
  $scope.submitText = "Create"

  $scope.client_member = new ClientMember({ client_id: Client.get().id })

  User.all().then (users) ->
    $scope.users = users

  Field.defaults($scope.client_member, 'Client').then (fields) ->
    $scope.client_member.role = Field.field($scope.client_member, 'Member Role')

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.client_member.$save ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()
]
