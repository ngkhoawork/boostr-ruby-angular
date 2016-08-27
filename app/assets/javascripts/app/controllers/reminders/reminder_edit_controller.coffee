@app.controller 'ReminderEditController',
  ['$scope', '$modal', '$modalInstance', '$q', '$location', 'Reminder', 'itemId', 'itemType', '$http'
    ($scope, $modal, $modalInstance, $q, $location, Reminder, itemId, itemType, $http) ->

      $scope.showMeridian = true
      $scope.reminder = {
        name: '',
        comment: '',
        remind_on: '',
        remindable_id: 0,
        remindable_type: '' # "Activity", "Client", "Contact", "Deal"
        _date: new Date(),
        _time: new Date()
      }
      editMode = false;
      $scope.errors = {}
      $scope.buttonDisabled = false

      $scope.init = ->
        $scope.formType = 'New'
        $scope.submitText = 'Set Reminder'
        $scope.itemId = itemId
        $scope.itemType = itemType
        #    Reminder.get($scope.reminder.remindable_id, $scope.reminder.remindable_type).then (reminder) ->
        $http.get('/api/remindable/'+ $scope.reminder.remindable_id + '/' + $scope.reminder.remindable_type)
        .then (respond) ->
          if (respond && respond.data && respond.data.length)
            _.each respond.data, (reminder) ->
              if (reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
                $scope.reminder.id = reminder.id
                $scope.reminder.name = reminder.name
                $scope.reminder.comment = reminder.comment
                $scope.reminder.completed = reminder.completed
                $scope.reminder._date = new Date(reminder.remind_on)
                $scope.reminder._time = new Date(reminder.remind_on)
                $scope.reminderOptions.editMode = true
                editMode = true


      $scope.submitForm = () ->
        $scope.errors = {}
        $scope.buttonDisabled = true
        reminder_date = new Date($scope.reminder._date)
        if $scope.reminder._time != undefined
          reminder_time = new Date($scope.reminder._time)
          reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
        $scope.reminder.remind_on = reminder_date
        $scope.reminder.remindable_id = itemId
        $scope.reminder.remindable_type = itemType
        if (editMode)
          Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
          .then (reminder) ->
                 $scope.buttonDisabled = false
#                 $scope.reminder = reminder
#                 $scope.reminder._date = new Date($scope.reminder.remind_on)
#                 $scope.reminder._time = new Date($scope.reminder.remind_on)
                 $modalInstance.close()
              , (err) ->
                $scope.buttonDisabled = false
        else
          Reminder.create(reminder: $scope.reminder).then (reminder) ->
            $scope.buttonDisabled = false
#            $scope.reminder = reminder
#            $scope.reminder._date = new Date($scope.reminder.remind_on)
#            $scope.reminder._time = new Date($scope.reminder.remind_on)
            $modalInstance.close()
          , (err) ->
            $scope.buttonDisabled = false
      $scope.cancel = ->
        $modalInstance.close()

      $scope.init()
  ]
