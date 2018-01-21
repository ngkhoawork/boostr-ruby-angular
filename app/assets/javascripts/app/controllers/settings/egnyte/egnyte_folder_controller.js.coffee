@app.controller 'EgnyteFolderController',
  ['$scope', '$modal', ( $scope, $modal ) ->
    $scope.showParentButton = false
    $scope.showSubButton = false

    $scope.folders = nodes: [
      {
        id: 1,
        title: 'Deal'
        root: true
        nodes: [
          {
            id: 2,
            title: 'Images'
            nodes: [
              { id: 3, title: 'Mockups' }
              { id: 4, title: 'Templates' }
              { id: 50, title: 'PNG', nodes: [
                { id: 50, title: 'test', nodes: [
                  { id: 50, title: 'test', nodes: [] }
                  ]}
              ] }
            ]
          }
          {
            id: 5,
            title: 'Proposal'
            nodes: [
              { id: 6, title: 'Good Proposals' }
              { id: 7, title: 'Bad Proposals' }
            ]
          }
        ]
      }
    ]

    $scope.createFolder = () ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/egnyte_form.html'
        size: 'md'
        controller: 'EgnyteNewFolderController'
        backdrop: 'static'
        keyboard: false
        resolve:
          folder: ->
            {}

    $scope.$on 'handleActionButtons', (event, folder) ->
      if folder
        if folder.root
          $scope.showParentButton = false
          $scope.showSubButton = true
        else
          $scope.showSubButton = true
          $scope.showParentButton = true
      else
        $scope.showSubButton = false
        $scope.showParentButton = false




]