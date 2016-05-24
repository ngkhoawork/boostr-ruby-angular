@app.controller "ClientMembersNewController",
['$scope', '$rootScope', '$modalInstance', 'ClientMember', 'User', 'Field', 'client',
($scope, $rootScope, $modalInstance, ClientMember, User, Field, client) ->

  $scope.formType = "New"
  $scope.submitText = "Create"

  $scope.client_member = new ClientMember({ client_id: client.id })

  User.all().then (users) ->
    $scope.users = users

  Field.defaults($scope.client_member, 'Client').then (fields) ->
    $scope.client_member.role = Field.field($scope.client_member, 'Member Role')

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.client_member.$save ->
      $rootScope.$broadcast("new_client_member", { clientMember: $scope.client_member })
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()
]
