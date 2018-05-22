@app.controller "AgreementAssignMembersController",
['$scope', '$modal', '$modalInstance', 'User', 'Agreement', 'agreement'
($scope, $modal, $modalInstance, User, Agreement, agreement) ->
  $scope.showMembersDropdown = false
  membersClone = []

  init = ->
    getAvailableMembers()
    $scope.assignedMembers = []

  getAvailableMembers = ->
    User.query().$promise.then (members) ->
      $scope.members = members
      membersClone = members
      filterMembers()

  filterMembers = ->
    agreementMembers = agreement.team.map (member) -> id: member.user_id
    excludeMembers = _.uniq( $scope.assignedMembers.concat agreementMembers, 'id' )
    $scope.members = _.filter membersClone, (member) ->
      !_.findWhere( excludeMembers, { id: member.id } )

  $scope.selectMember = (member) ->
    isAssigned = false
    $scope.assignedMembers.forEach(
      (assignedMember, index) ->
        if member.id == assignedMember.id
          isAssigned = true
    )
    unless isAssigned
      $scope.assignedMembers.unshift(member)
      filterMembers()

  $scope.removeMember = (member) ->
    $scope.assignedMembers.forEach (assignedMember, index) ->
      if member.id == assignedMember.id
        $scope.assignedMembers.splice(index, 1)
    filterMembers()

  $scope.onModalClick = (event) ->
    target = angular.element(event.target)
    if target[0].className.includes("form-control-wrapper") || target.parents(".form-control-wrapper").length || target[0].className.includes('select')
      $scope.showMembersDropdown = true
    else
      $scope.showMembersDropdown = false

  $scope.showAddMemberModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/user_form.html'
      size: 'lg'
      controller: 'NewUsersController'
      backdrop: 'static'
      keyboard: false
      resolve:
        onInvite: -> null
        options: -> assignToAgreement: true
    .result.then (user) -> $scope.assignMembers.unshift(user) if user

  $scope.assignMembers = ->
    membersIds = $scope.assignedMembers.map((member) -> user_id: member.id)
    $modalInstance.close(membersIds)

  $scope.cancel = -> $modalInstance.close()

  init()

]
