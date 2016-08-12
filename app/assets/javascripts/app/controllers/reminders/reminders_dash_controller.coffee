@app.controller 'RemindersDashController',
  ['$scope', '$q', '$location', '$http', 'Reminder',
    ($scope, $q, $location, $http, Reminder) ->

      $scope.showMeridian = true
      editMode = false;
      $scope.errors = {}
      $scope.buttonDisabled = false

      $scope.init = ->
        $scope.reminders = []
        $scope.completedReminders = []
        $http.get('/api/reminders')
        .then (respond) ->
                console.log('respond', respond)
                if (respond && respond.data && respond.data.length)
                  _.each respond.data, (curReminder) ->
#                    curReminder.editMode = false
#                    curReminder.collapsed = true
                    curReminder._date = new Date(curReminder.remind_on)
                    curReminder._time = new Date(curReminder.remind_on)
                    if (curReminder.completed)
                      $scope.completedReminders.push(curReminder)
                    else
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

      $scope.save = (curReminder) ->
        console.log('I am a save')
        $scope.errors = {}
#        $scope.buttonDisabled = true
        reminder_date = new Date(curReminder._date)
        if curReminder._time != undefined
          reminder_time = new Date(curReminder._time)
          reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
        curReminder.remind_on = reminder_date
        Reminder.update(id: curReminder.id, reminder: curReminder)
        .then (reminder) ->
               console.log('Reminder update', reminder)
               $scope.init()
#                 $scope.buttonDisabled = false
#                 $scope.reminder = reminder
#                 $scope.reminder._date = new Date($scope.reminder.remind_on)
#                 $scope.reminder._time = new Date($scope.reminder.remind_on)
            , (err) ->
              console.log('err', err)
#                $scope.buttonDisabled = false

      $scope.delete = (curReminder) ->
        console.log('I am a delete')
        $scope.errors = {}
        #        $scope.buttonDisabled = true
        Reminder.delete(curReminder.id)
        .then (reminder) ->
          console.log('Reminder delete', reminder)
          $scope.init()
#                 $scope.buttonDisabled = false
#                 $scope.reminder = reminder
#                 $scope.reminder._date = new Date($scope.reminder.remind_on)
#                 $scope.reminder._time = new Date($scope.reminder.remind_on)
        , (err) ->
          console.log('err', err)
      #                $scope.buttonDisabled = false

      $scope.init()

#      $scope.switchDetailsVisibility = (curReminder) ->
#        console.log(curReminder)
#        if (curReminder.collapsed)
#          curReminder.collapsed = false
#        if (!curReminder.collapsed)
#          curReminder.collapsed = true
#        $scope.$$phase || $scope.$apply();
  ]
