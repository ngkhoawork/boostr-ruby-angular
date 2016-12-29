@app.controller "DashboardReminderEditController",
    ['$scope', '$rootScope', '$modalInstance', 'Reminder', 'reminder',
        ($scope, $rootScope, $modalInstance, Reminder, reminder) ->
            console.log(reminder)

            if reminder
                $scope.reminder = angular.copy reminder

            $scope.cancel = ->
                $modalInstance.close()

            $scope.submitForm = ->
                $scope.errors = {}

                fields = ['name', '_date', 'comment']

                fields.forEach (key) ->
                    field = $scope.reminder[key]
                    switch key
                        when 'name'
                            if !field
                                return $scope.errors[key] = 'Name is required'
                        when '_date'
                            if !field
                                return $scope.errors[key] = 'Date is required'
                        when 'comment'
                            if !field
                                return $scope.errors[key] = 'Comment is required'

                if Object.keys($scope.errors).length > 0 then return
                if $scope.reminder
                    console.log($scope.reminder)
                    reminder_date = $scope.reminder._date
                    if $scope.reminder._time
                        reminder_time = new Date($scope.reminder._time)
                        reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
                    $scope.reminder.remind_on = reminder_date
                    Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
                        .then (reminder) ->
                            $scope.cancel()
                            $rootScope.$broadcast 'dashboard.updateBlocks', ['reminders']
                        , (err) ->
                            console.log(err)
    ]
