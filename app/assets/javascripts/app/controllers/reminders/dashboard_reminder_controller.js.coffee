@app.controller "DashboardReminderController",
    ['$scope', '$rootScope', '$modalInstance', 'Reminder', 'Deal', 'Client', 'Contact', 'reminder',
    ( $scope,   $rootScope,   $modalInstance,   Reminder,   Deal,   Client,   Contact,   reminder ) ->

        $scope.modalType = 'New'
        $scope.submitType = 'Create'
        $scope.reminderTypes = ['Deal', 'Account', 'Contact']
        $scope.reminder = reminder ||
            name: '',
            comment: '',
            completed: false,
            remind_on: '',
            remindable: null,
            remindable_id: null,
            remindable_type: ''
            _date: new Date(),
            _time: new Date()


        if reminder
            $scope.modalType = 'Edit'
            $scope.submitType = 'Save'
            if reminder.remindable_type == 'Client'
              reminder.remindable_type = 'Account'
            reminder.remindable.formatted_name = reminder.remindable.name if reminder.remindable

        $scope.searchDeals = (str) ->
            Deal.all({name: str}).then (deals) ->
                deals

        $scope.searchClients = (str) ->
            Client.query(search: str, filter: 'all').$promise.then (clients) ->
                clients

        $scope.searchContacts = (str) ->
            Contact.all1(q: str, per: 10).then (contacts) ->
                contacts

        $scope.cancel = ->
            $modalInstance.close()

        $scope.submitForm = ->
            $scope.errors = {}

            fields = ['name', '_date']

            fields.forEach (key) ->
                field = $scope.reminder[key]
                switch key
                    when 'name'
                        if !field
                            return $scope.errors[key] = 'Name is required'
                    when '_date'
                        if !field
                            return $scope.errors[key] = 'Date is required'

            if Object.keys($scope.errors).length > 0 then return
            if $scope.reminder
                if $scope.reminder.remindable_type && $scope.reminder.remindable
                  if $scope.reminder.remindable_type == 'Account'
                    $scope.reminder.remindable_type = 'Client'
                  $scope.reminder.assigned = true
                  $scope.reminder.remindable_id = $scope.reminder.remindable.id
                else
                    $scope.reminder.assigned = false
                    $scope.reminder.remindable_id = null
                    $scope.reminder.remindable_type = ''

                reminder_date = $scope.reminder._date
                if $scope.reminder._time
                    reminder_time = new Date($scope.reminder._time)
                    reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
                $scope.reminder.remind_on = reminder_date
            if reminder
                Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
                    .then (reminder) ->
                        $scope.cancel()
                        $rootScope.$broadcast 'dashboard.updateBlocks', ['reminders']
                    , (err) ->
                        console.log(err)
            else
                Reminder.create(reminder: $scope.reminder)
                    .then (reminder) ->
                        $scope.cancel()
                        $rootScope.$broadcast 'dashboard.updateBlocks', ['reminders']
                    , (err) ->
                        console.log(err)
    ]
