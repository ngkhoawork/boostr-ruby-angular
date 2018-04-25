@app.controller 'LeadsRejectionController',
[ '$scope', '$modalInstance', 'Leads', 'lead'
( $scope, $modalInstance, Leads, lead ) ->
  init = ->
    $scope.formType = 'Rejection Explanation'
    $scope.commentText = 'Rejection Explanation Comment'
    $scope.submitText = 'Submit'
    $scope.rejectionComment = ''

  $scope.submitForm = () ->
    $scope.errors = {}
    if !$scope.rejectionComment
      $scope.errors.comment = 'Comment is required'
      return
    
    Leads.update( id: lead.id, { lead: { rejected_reason: $scope.rejectionComment } } )
        .then (newLead) -> $modalInstance.close(newLead)

  $scope.cancel = -> $modalInstance.close()

  init()
]
