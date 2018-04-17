@app.controller 'WorkflowFormController',
  ['$scope', '$modalInstance', 'Workflows', 'WorkflowCriterions', 'workflow', 'data_models', 'data_mappings', 'ApiConfiguration', 'CurrentUser'
    ($scope, $modalInstance, Workflows, WorkflowCriterions, workflow, data_models, data_mappings, ApiConfiguration, CurrentUser) ->
      $scope.data_models = data_models
      $scope.showSearch = false
      $scope.default_criterion = {relation: 'AND'}
      $scope.workflow = {
        workflow_criterions: [angular.copy $scope.default_criterion],
        workflow_action: {},
        workflowable_type: 'Deal',
        switched_on: true,
        fire_on_create: false,
        fire_on_update: false,
        fire_on_destroy: false
      }
      $scope.headerPrefix = 'New'
      $scope.submitButtonText = 'Add Event'

      $scope.defaults = {
        relations: ['AND', 'OR'],
        math_operators: ['=', '>', '<', '>=', '<=', '!=', 'contains', 'ends_with', 'starts_with'],
        integrations: [{name: 'Post to Slack', action: 'slack_message'}],
        methods: ['Channel=']
      }

      CurrentUser.get().$promise.then (user) ->
        $scope.currentUser = user

      $scope.data_mappings = data_mappings

      ApiConfiguration.workflowable_actions().then (data) ->
        $scope.workflowable_actions = data

      $scope.setActionId = (workflow, selected_action) ->
        workflow.workflow_action.api_configuration_id = selected_action.id

      $scope.oneMoreCriteria = () ->
        $scope.workflow.workflow_criterions.push(angular.copy $scope.default_criterion)

      $scope.removeCriterion = (criterion) ->
        index = $scope.workflow.workflow_criterions.indexOf(criterion)

        if $scope.workflow.id? && criterion.id?
          WorkflowCriterions.delete(id: criterion.id, workflow_id: $scope.workflow.id).then (data) ->
            $scope.workflow.workflow_criterions.splice(index, 1)
          , (err) ->
            console.log err
        else
          $scope.workflow.workflow_criterions.splice(index, 1)

      $scope.setDataModel = (criterion) ->
        if criterion? && criterion.base_object?
          criterion.data_model = _.findWhere $scope.data_models, name: criterion.base_object
          if criterion.base_object == 'deal'
            criterion.data_model.model_attributes.push({field_name: "currencies", field_label: "Currency", data_type: "relation", sql_type: "custom"})
            criterion.data_model.model_attributes.push({field_name: "teams", field_label: "Creator Team", data_type: "relation", sql_type: "custom"})
            criterion.data_model.model_attributes.push({field_name: "deal_type", field_label: "Type", data_type: "relation", sql_type: "custom"})
            criterion.data_model.model_attributes.push({field_name: "deal_initiative", field_label: "Initiative", data_type: "relation", sql_type: "custom"})
          if criterion.base_object == 'Advertiser'
            criterion.data_model.model_attributes.push({field_name: "client_segments", field_label: "Segment", data_type: "relation", sql_type: "custom"})
            criterion.data_model.model_attributes.push({field_name: "client_regions", field_label: "Region", data_type: "relation", sql_type: "custom"})
            criterion.data_model.model_attributes.push({field_name: "client_categories", field_label: "Category", data_type: "relation", sql_type: "custom"})
            criterion.data_model.model_attributes.push({field_name: "client_subcategories", field_label: "Sub Category", data_type: "relation", sql_type: "custom"})
          if criterion.base_object == 'Products'
            arr = [];
            if $scope.currentUser.product_options_enabled
              name = 'name'
            else
              name = 'full_name'
            angular.forEach criterion.data_model.model_attributes, (item) =>
              if item.field_name != name
                arr.push(item)
            criterion.data_model.model_attributes = arr

      $scope.setCurrentDataType = (criterion, dataType) ->
        criterion.data_type = dataType

      $scope.setDataModels = (workflow) ->

        if workflow?
          _.each workflow.workflow_criterions, (criterion) ->
            criterion.data_model = _.findWhere $scope.data_models, name: criterion.base_object
            if criterion.base_object == 'deal'
              criterion.data_model.model_attributes.push({field_name: "currencies", field_label: "Currency", data_type: "relation", sql_type: "custom"})
              criterion.data_model.model_attributes.push({field_name: "teams", field_label: "Creator Team", data_type: "relation", sql_type: "custom"})
              criterion.data_model.model_attributes.push({field_name: "deal_type", field_label: "Type", data_type: "relation", sql_type: "custom"})
              criterion.data_model.model_attributes.push({field_name: "deal_initiative", field_label: "Initiative", data_type: "relation", sql_type: "custom"})
            if criterion.base_object == 'Advertiser'
              criterion.data_model.model_attributes.push({field_name: "client_segments", field_label: "Segment", data_type: "relation", sql_type: "custom"})
              criterion.data_model.model_attributes.push({field_name: "client_regions", field_label: "Region", data_type: "relation", sql_type: "custom"})
              criterion.data_model.model_attributes.push({field_name: "client_categories", field_label: "Category", data_type: "relation", sql_type: "custom"})
              criterion.data_model.model_attributes.push({field_name: "client_subcategories", field_label: "Sub Category", data_type: "relation", sql_type: "custom"})
            if criterion.base_object == 'Products'
              arr = [];
              if $scope.currentUser.product_options_enabled
                name = 'name'
              else
                name = 'full_name'
              angular.forEach criterion.data_model.model_attributes, (item) =>
                if item.field_name != name
                  arr.push(item)
              criterion.data_model.model_attributes = arr


      if workflow?
        $scope.workflow = workflow
        $scope.headerPrefix = 'Edit'
        $scope.submitButtonText = 'Save'
        $scope.setDataModels(workflow)

      $scope.cancel = ->
        $modalInstance.close()

      $scope.toogleSearch = ->
        $scope.showSearch = !$scope.showSearch
        return

      $scope.dontShowSuggestion = (suggestion) ->
        if $scope.workflow.workflow_action.slack_attachment_mappings
          !ans = $scope.workflow.workflow_action.slack_attachment_mappings.some(
            (mapping) -> mapping.name == suggestion.name
          )
        else
          true

      $scope.addSuggestion = (suggestion) ->
        if $scope.workflow.workflow_action.slack_attachment_mappings
          mappingAdded = false
          $scope.workflow.workflow_action.slack_attachment_mappings.forEach(
            (mapping) ->
              if mapping.name == suggestion.name then mappingAdded = true
          )
          unless mappingAdded
            $scope.workflow.workflow_action.slack_attachment_mappings.push(suggestion)
        else
          $scope.workflow.workflow_action.slack_attachment_mappings = []
          $scope.workflow.workflow_action.slack_attachment_mappings.push(suggestion)

      $scope.removeSuggestion = (suggestion) ->
        $scope.workflow.workflow_action.slack_attachment_mappings.forEach(
          (mapping, index) ->
            if mapping.name == suggestion.name
              $scope.workflow.workflow_action.slack_attachment_mappings.splice(index, 1)
        )

      $scope.onMoved = (mapping, index) ->
        $scope.workflow.workflow_action.slack_attachment_mappings.splice(index, 1)

      $scope.hideSearch = (event) ->
        if $(event.target).closest('.add-mapping').length == 0 and $(event.target).parent('.search-mapping-wrapper').length == 0
          $scope.showSearch = false

      $scope.submitForm = ->
        if workflow
          Workflows.update($scope.workflow).then (data) ->
            $scope.cancel()
          , (err) ->
            console.log err
        else
          Workflows.create($scope.workflow).then (data) ->
            $scope.cancel()
          , (err) ->
            console.log err
  ]
