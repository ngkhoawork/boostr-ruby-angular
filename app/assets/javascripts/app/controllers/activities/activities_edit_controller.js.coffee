@app.controller "ActivitiesEditController",
  ['$scope', '$modalInstance', '$modal', '$filter', 'Activity', 'ActivityType', 'Field', 'activity', 'types', 'contacts'
    ($scope, $modalInstance, $modal, $filter, Activity, ActivityType, Field, activity, types, contacts) ->
      $scope.showMeridian = true
      $scope.selectedContacts = []

      $scope.init = () ->
        $scope.populateContact = false
        $scope.formType = "Edit"
        $scope.submitText = "Update"
        $scope.activity = angular.copy(activity)
        if (activity.activity_type)
          $scope.activity.activity_type_id = activity.activity_type.id
          $scope.activity.activity_type_name = activity.activity_type.name
        if (!activity.client_id && activity.client)
          $scope.activity.client_id = activity.client.id
        if (!activity.deal_id && activity.deal)
          $scope.activity.deal_id = activity.deal.id

        $scope.types = types
        $scope.contacts = contacts
        $scope.activeTab ='Type'

        $scope.activeType = _.find types, (type) ->
          if (type.id==$scope.activity.activity_type_id)
            return type
        $scope.date =new Date($scope.activity.happened_at)
        $scope.time =new Date($scope.activity.happened_at)

        $scope.selected = {}
        now = new Date

        $scope.selected.date = new Date($scope.activity.happened_at)
        if ($scope.activity.timed == true)
          $scope.selected.time = new Date($scope.activity.happened_at)
        $scope.selected.contacts = _.map $scope.activity.contacts, (contact) ->
          return contact.id
      $scope.setActiveTab = (tab) ->
        $scope.activeTab = tab

      $scope.setActiveType = (type) ->
        $scope.activeType = type

      $scope.submitForm = (form) ->
        $scope.errors = {}
        $scope.buttonDisabled = true

        if form.$valid
          if !$scope.activity.comment
            $scope.buttonDisabled = false
            $scope.errors['Comment'] = ["can't be blank."]
          if !($scope.activeType && $scope.activeType.id)
            $scope.buttonDisabled = false
            $scope.errors['Activity Type'] = ["can't be blank."]
          if $scope.selected.contacts.length == 0
            $scope.buttonDisabled = false
            $scope.errors['Contacts'] = ["can't be blank."]
          if !$scope.buttonDisabled
            return
          form.submitted = true

          activity_data = {}
          activity_data.activity_type_id = $scope.activeType.id
          activity_data.activity_type_name = $scope.activeType.name
          contact_date = new Date($scope.selected.date)
          if $scope.selected.time != undefined
            contact_time = new Date($scope.selected.time)
            contact_date.setHours(contact_time.getHours(), contact_time.getMinutes(), 0, 0)
            activity_data.timed = true
          activity_data.happened_at = contact_date
          activity_data.comment = $scope.activity.comment
          activity_data.client_id = $scope.activity.client_id
          activity_data.deal_id = $scope.activity.deal_id

          Activity.update(id: $scope.activity.id, activity: activity_data, contacts: $scope.selected.contacts, (response) ->
            $scope.buttonDisabled = false
          ).then (activity) ->
            $scope.buttonDisabled = false
            $modalInstance.dismiss()

      $scope.createNewContactModal = ->
        $scope.populateContact = true
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/contact_form.html'
          size: 'lg'
          controller: 'ContactsNewController'
          backdrop: 'static'
          keyboard: false
          resolve:
            contact: ->
              {}

      $scope.$on 'newContact', (event, contact) ->
        if $scope.populateContact
          $scope.contacts.push(contact)
          $scope.selected.contacts.push(contact.id)
          $scope.populateContact = false
      $scope.cancel = ->
        $scope.init()
        $modalInstance.dismiss()

      $scope.init()
  ]
