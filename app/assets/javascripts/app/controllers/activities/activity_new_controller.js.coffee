@app.controller "ActivityNewController",
    ['$scope', '$rootScope', '$modalInstance', 'Activity', 'ActivityType', 'Deal', 'Client', 'Contact', 'Reminder', 'activity', '$http'
        ($scope, $rootScope, $modalInstance, Activity, ActivityType, Deal, Client, Contact, Reminder, activity, $http) ->

            $scope.types = []
            $scope.showMeridian = true
            $scope.submitButtonText = 'Add Activity'
            $scope.selectedType =
                action: 'had initial meeting with'
            $scope.form = {
                contacts: []
            }
            $scope.errors = {}

            $scope.reminder =
                _date: new Date()
                _time: new Date()
                name: ''
                comment: ''
                completed: false
                remind_on: ''
                remindable_id: 0
                remindable_type: 'Activity'
                showSpinners: false

            #edit mode
            if activity
                $scope.submitButtonText = 'Save'
                if activity.deal
                    activity.deal.formatted_name = activity.deal.name
                    $scope.form.deal = activity.deal
                if activity.client
                    $scope.form.advertiser = activity.client
                    $scope.form.advertiser.formatted_name = $scope.form.advertiser.name
                if activity.agency
                    $scope.form.agency = activity.agency
                    $scope.form.agency.formatted_name = $scope.form.agency.name
                $scope.form.contacts = activity.contacts
                $scope.form.date = new Date(activity.happened_at)
                if activity.timed
                    $scope.form.time = new Date(activity.happened_at)
                $scope.form.comment = activity.comment
                $http.get('/api/remindable/'+ activity.id + '/' + $scope.reminder.remindable_type)
                    .then (respond) ->
                        if (respond && respond.data && respond.data.length)
                            _.each respond.data, (reminder) ->
                                if (reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
                                    $scope.showReminderForm = true;
                                    $scope.reminder.id = reminder.id
                                    $scope.form.reminderName = reminder.name
                                    $scope.form.reminderComment = reminder.comment
                                    $scope.form.reminderDate = new Date(reminder.remind_on)
                                    $scope.form.reminderTime = new Date(reminder.remind_on)
#                                    $scope.editActivityReminder.remind_on = new Date(reminder.remind_on)
#                                    $scope.editActivityReminder.completed = reminder.completed



            $scope.contacts = []
            $scope.showReminderForm = false

            $scope.selectType = (type) ->
                $scope.selectedType = type
                $scope.form.type = type.id
            ActivityType.all().then (activityTypes) ->
                activityTypes.forEach (type) ->
                    type.iconName = type.name.split(" ").join("-").toLowerCase()
                $scope.types = activityTypes
                if activity
                    $scope.selectedType = _.findWhere(activityTypes, name: activity.activity_type_name)
                    $scope.form.type = activity.activity_type_id
                else
                    $scope.selectedType = activityTypes[0]
                    $scope.form.type = activityTypes[0].id

            Contact.query().$promise.then (contacts) ->
                $scope.contacts = contacts
            $scope.onDealSelect = (item, model, label, event) ->
                if !item then return
                if item.advertiser_id
                    Client.get({id: item.advertiser_id }).$promise.then (client) ->
                        if client
                            client.formatted_name = client.name
                            $scope.form.advertiser = client
                if item.agency_id
                    Client.get({id: item.agency_id }).$promise.then (client) ->
                        if client
                            client.formatted_name = client.name
                            $scope.form.agency = client

            $scope.searchDeals = (str) ->
                Deal.all({name: str}).then (deals) ->
                    deals

            $scope.searchClients = (str, type) ->
                q =
                    name: str
                if type is 'advertiser' then q.client_type_id = 111
                if type is 'agency' then q.client_type_id = 112
                Client.query(q).$promise.then (clients) ->
                    clients

            $scope.searchContacts = (str) ->
                if ($scope.contactSearchText != str)
                    $scope.contactSearchText = str
                    query = per: 10, page: 1
                    if $scope.contactSearchText then query.contact_name = $scope.contactSearchText
                    Contact.all1(query).then (contacts) ->
                        contacts = contacts.filter (c)->
                            $scope.form.contacts.indexOf(c.id) == -1
                        $scope.contacts = contacts
                str

            $scope.getType = (type) ->
                _.findWhere($scope.types, name: type)

            $scope.openContactModal = ->
                $rootScope.$broadcast 'dashboard.openContactModal'

            $scope.openAccountModal = ->
                $rootScope.$broadcast 'dashboard.openAccountModal'

            $scope.cancel = ->
                $modalInstance.close()

            $scope.submitForm = ->
                $scope.errors = {}

                fields = ['deal', 'advertiser', 'agency', 'contacts', 'date', 'comment']
                if $scope.showReminderForm
                    fields.push('reminderName', 'reminderDate', 'reminderComment')

                fields.forEach (key) ->
                    field = $scope.form[key]
                    switch key
                        when 'deal'
                            if !field && !$scope.form.advertiser && !$scope.form.agency
                                return $scope.errors[key] = 'At least one is required'
                            if field && typeof field != 'object'
                                return $scope.errors[key] = 'Record doesn\'t exist'
                        when 'advertiser'
                            if !field && !$scope.form.deal && !$scope.form.agency
                                return $scope.errors[key] = ' '
                            if field && typeof field != 'object'
                                return $scope.errors[key] = 'Record doesn\'t exist'
                        when 'agency'
                            if !field && !$scope.form.advertiser && !$scope.form.deal
                                return $scope.errors[key] = ' '
                            if field && typeof field != 'object'
                                return $scope.errors[key] = 'Record doesn\'t exist'
                        when 'date'
                            if !field
                                return $scope.errors[key] = 'Date is required'
                        when 'contacts'
                            if !field || !field.length
                                return $scope.errors[key] = 'Contact is required'
                        when 'comment'
                            if !field
                                return $scope.errors[key] = 'Comment is required'
                        when 'reminderName'
                            if !field
                                return $scope.errors[key] = 'Name is required'
                        when 'reminderDate'
                            if !field
                                return $scope.errors[key] = 'Date is required'
                        when 'reminderComment'
                            if !field
                                return $scope.errors[key] = 'Comment is required'

                if Object.keys($scope.errors).length > 0 then return

                activityData =
                    activity_type_id: $scope.selectedType.id
                    activity_type_name: $scope.selectedType.name
                    comment: $scope.form.comment
                    happened_at: $scope.form.date
                    timed: false
                if $scope.form.time && $scope.form.time.getTime
                    activityData.timed = true
                    activityData.happened_at.setHours($scope.form.time.getHours(), $scope.form.time.getMinutes(), 0)
                if $scope.form.deal
                    activityData.deal_id = $scope.form.deal.id
                    activityData.client_id = $scope.form.deal.advertiser_id
                    activityData.agency_id = $scope.form.deal.agency_id
                else
                    if $scope.form.advertiser
                        activityData.client_id = $scope.form.advertiser.id
                    if $scope.form.agency
                        activityData.agency_id = $scope.form.agency.id

                if activity
                    if $scope.form.contacts && $scope.form.contacts[0] && typeof $scope.form.contacts[0] == 'object'
                        $scope.form.contacts = $scope.form.contacts.map (c) -> c.id
                    updateActivity(activity.id, activityData, $scope.form.contacts)
                else
                    createActivity(activityData, $scope.form.contacts)




            createActivity = (activity, contacts) ->
                Activity.create({
                    activity: activity
                    contacts: contacts
                }, (response) ->
                    #response
                ).then (activity) ->
                    if (activity && activity.id && $scope.showReminderForm)
                        $scope.reminder._date = $scope.form.reminderDate
                        $scope.reminder._time = $scope.form.reminderTime
                        $scope.reminder.name = $scope.form.reminderName
                        $scope.reminder.comment = $scope.form.reminderComment
                        reminder_date = new Date($scope.reminder._date)
                        $scope.reminder.remindable_id = activity.id
                        if $scope.reminder._time != undefined
                            reminder_time = new Date($scope.reminder._time)
                            reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
                        $scope.reminder.remind_on = reminder_date
                        Reminder.create(reminder: $scope.reminder).then (reminder) ->
                            $scope.cancel()
                            $rootScope.$broadcast 'dashboard.updateBlocks', ['activities', 'reminders']
                        , (err) ->
                            console.log(err)
                    else
                        $scope.cancel()
                        $rootScope.$broadcast 'dashboard.updateBlocks', ['activities']

            updateActivity = (id, activity, contacts) ->
                Activity.update({
                    id: id
                    activity: activity
                    contacts: contacts
                }, (response) ->
                    #response
                ).then (activity) ->
                    if (activity && activity.id && $scope.showReminderForm)
                        $scope.reminder._date = $scope.form.reminderDate
                        $scope.reminder._time = $scope.form.reminderTime
                        $scope.reminder.name = $scope.form.reminderName
                        $scope.reminder.comment = $scope.form.reminderComment
                        reminder_date = new Date($scope.reminder._date)
                        $scope.reminder.remindable_id = activity.id
                        if $scope.reminder._time != undefined
                            reminder_time = new Date($scope.reminder._time)
                            reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
                        $scope.reminder.remind_on = reminder_date
                        if $scope.reminder.id
                            Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
                                .then (reminder) ->
                                    $scope.cancel()
                                    $rootScope.$broadcast 'dashboard.updateBlocks', ['activities', 'reminders']
                                , (err) ->
                                    console.log(err)
                        else
                            Reminder.create(reminder: $scope.reminder).then (reminder) ->
                                $scope.cancel()
                                $rootScope.$broadcast 'dashboard.updateBlocks', ['activities', 'reminders']
                            , (err) ->
                                console.log(err)
                    else
                        $scope.cancel()
                        $rootScope.$broadcast 'dashboard.updateBlocks', ['activities']
    ]
