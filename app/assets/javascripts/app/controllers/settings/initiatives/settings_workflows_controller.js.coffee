@app.controller 'SettingsWorkflowsController',
  ['$scope', '$modal', 'Workflows', 'DataModel'
    ($scope, $modal, Workflows, DataModel) ->
      $scope.workflows = []
      $scope.data_models = []
      $scope.data_mappings = []

      getWorkflows = ->
        Workflows.all().then (data) ->
          $scope.workflows = data
        , (err) ->
          console.log err

      getDataModel = ->
        DataModel.all(object_name: 'Deal').then (data) ->
          data.data_model.unshift data.base_model
          $scope.data_models = data
        , (err) ->
          console.log err

      getDataMappings = ->
        DataModel.get_mappings(object_name: 'Deal').then (mappings) ->
          $scope.data_mappings = mappings

      $scope.showWorkflowModal = (workflow) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/workflow_form.html'
          size: 'lg'
          controller: 'WorkflowFormController'
          backdrop: 'static'
          keyboard: false
          resolve:
            workflow: ->
              angular.copy workflow
            data_models: ->
              angular.copy $scope.data_models.data_model
            data_mappings: ->
              angular.copy $scope.data_mappings

      $scope.deleteWorkflow = (workflow) ->
        if confirm('Are you sure you want to delete "' +  workflow.name + '"?')
          Workflows.delete(workflow).then(
            (workflow) ->
              (err) ->
                console.log err
          )

      $scope.init = () ->
        getWorkflows()
        getDataModel()
        getDataMappings()

      $scope.init()

      $scope.$on 'workflows_updated', getWorkflows
  ]
