@app.controller 'RemindersDashController',
  ['$scope', '$q', '$location', '$http', 'Reminder',
    ($scope, $q, $location, $http, Reminder) ->

      $scope.showMeridian = true
      editMode = false;
      $scope.errors = {}
      $scope.buttonDisabled = false
      $scope.reminders = []
      $scope.collapsed = true

      $scope.init = ->
        $http.get('/api/reminders')
        .then (respond) ->
                console.log('respond', respond)
                if (respond && respond.data && respond.data.length)
                  _.each respond.data, (curReminder) ->
                    curReminder.editMode = false
                    curReminder.collapsed = true
                    $scope.reminders.push(curReminder)

                console.log('$scope.reminders', $scope.reminders)
            , (err) ->
                console.log('err', err)

#        Reminder.all($scope.itemId, $scope.itemType).then (reminder) ->
#          console.log('Reminder', reminder)
#          if (reminder && reminder.id)
#            $scope.reminder.id = reminder.id
#            $scope.reminder.name = reminder.name
#            $scope.reminder.comment = reminder.comment
#            $scope.reminder._date = new Date(reminder.remind_on)
#            $scope.reminder._time = new Date(reminder.remind_on)
#            editMode = true
#
#
#      $scope.submitForm = () ->
#        console.log('I am a submit')
#        $scope.errors = {}
#        $scope.buttonDisabled = true
#        reminder_date = new Date($scope.reminder._date)
#        if $scope.reminder._time != undefined
#          reminder_time = new Date($scope.reminder._time)
#          reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
#        $scope.reminder.remind_on = reminder_date
#        $scope.reminder.remindable_id = itemId
#        $scope.reminder.remindable_type = itemType
#        if (editMode)
#          Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
#          .then (reminder) ->
#                 console.log('Reminder update', reminder)
#                 $scope.buttonDisabled = false
##                 $scope.reminder = reminder
##                 $scope.reminder._date = new Date($scope.reminder.remind_on)
##                 $scope.reminder._time = new Date($scope.reminder.remind_on)
#              , (err) ->
#                console.log('err', err)
#                $scope.buttonDisabled = false
#        else
#          Reminder.create(reminder: $scope.reminder).then (reminder) ->
#            console.log('Reminder create', reminder)
#            $scope.buttonDisabled = false
##            $scope.reminder = reminder
##            $scope.reminder._date = new Date($scope.reminder.remind_on)
##            $scope.reminder._time = new Date($scope.reminder.remind_on)
#          , (err) ->
#            console.log('err', err)
#            $scope.buttonDisabled = false

      $scope.init()

      $scope.switchDetailsVisibility = (curReminder) ->
        console.log(curReminder)
        if (curReminder.collapsed)
          curReminder.collapsed = false
        if (!curReminder.collapsed)
          curReminder.collapsed = true
        $scope.$$phase || $scope.$apply();
  ]
