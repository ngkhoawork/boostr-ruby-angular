@app.controller "ActivityNewController", [
    '$scope', '$rootScope', 'CustomFieldNames', '$modalInstance', 'Activity', 'ActivityType', 'Deal', 'Client', 'Field', 'Contact', 'Publisher', 'Reminder', 'activity', 'options', '$http'
    ($scope,   $rootScope, CustomFieldNames,   $modalInstance,   Activity,   ActivityType,   Deal,   Client,   Field,   Contact,   Publisher,   Reminder,   activity,   options,   $http) ->

            $scope.types = []
            $scope.isPublisherEnabled = _isPublisherEnabled
#            $scope.isInfluencerEnabled = _isCompanyInfluencerEnabled
            $scope.showRelated = true
            $scope.showMeridian = true
            $scope.isEdit = Boolean activity
            $scope.submitButtonText = 'Add Activity'
            $scope.popupTitle = 'Add New Activity'
            $scope.selectedType =
                action: 'had initial meeting with'
            $scope.form = {
                date: new Date()
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

            #modal source dispatch
            if options
                $scope.showRelated = $scope.isEdit
                switch options.type
                    when 'deal'
                        $scope.form.deal = options.data
                    when 'account'
                        if options.isAdvertiser
                            $scope.form.advertiser = options.data
                        else
                            $scope.form.agency = options.data
                    when 'contact'
                        $scope.currentContact = options.data
                        $scope.form.contacts.push options.data
                        if $scope.isEdit then break
                        if options.isAdvertiser
                            $scope.form.advertiser =
                                id: options.data.client_id
                        else
                            $scope.form.agency =
                                id: options.data.client_id
                    when 'gmail'
                        $scope.showRelated = true
                        $scope.form = _.extend $scope.form, options.data
                    when 'publisher'
                        $scope.form.publisher = options.data
                        $scope.form.advertiser =
                            id: $scope.form.publisher.client_id

            #edit mode
            if activity
                $scope.popupTitle = 'Edit Activity'
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
                if activity.publisher
                    $scope.form.publisher = activity.publisher
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

            CustomFieldNames.all({subject_type: 'activity', show_on_modal: true}).then (customFieldNames) ->
              $scope.customFieldNames = customFieldNames
              console.log($scope.customFieldNames)
              console.log("66666666666666666")

            $scope.selectType = (type) ->
                $scope.selectedType = type
                $scope.form.type = type.id
            ActivityType.all().then (activityTypes) ->
                activityTypes.forEach (type) ->
                    type.iconName = type.name.split(" ").join("-").toLowerCase()
                $scope.types = activityTypes
                if activity
                    activityType = activity.activity_type
                    $scope.selectedType = activityType || _.findWhere(activityTypes, name: activity.activity_type_name)
                    $scope.form.type = (activityType && activityType.id) || activity.activity_type_id
                else
                    $scope.selectedType = activityTypes[0]
                    $scope.form.type = activityTypes[0].id
                if options && options.type == 'gmail'
                    $scope.selectType _.findWhere($scope.types, name: 'Email')

            Contact.query().$promise.then (contacts) ->
                $scope.contacts = contacts

            $scope.searchPublishers = (str) ->
                Publisher.publishersList(q: str).then (publishers) -> publishers

            Field.defaults({}, 'Client').then (fields) ->
                client_types = Field.findClientTypes(fields)
                client_types.options.forEach (option) ->
                    $scope[option.name] = option.id

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
                    search: str
                    filter: 'all'
                if type is 'advertiser' then q.client_type_id = $scope.Advertiser
                if type is 'agency' then q.client_type_id = $scope.Agency
                Client.query(q).$promise.then (clients) ->
                    clients

            $scope.searchContacts = (str) ->
                if ($scope.contactSearchText != str)
                    $scope.contactSearchText = str
                    query = per: 10, page: 1
                    if $scope.contactSearchText then query.q = $scope.contactSearchText
                    Contact.all1(query).then (contacts) ->
                        contacts = contacts.filter (c)->
                            $scope.form.contacts.indexOf(c.id) == -1
                        $scope.contacts = contacts
                str

            $scope.openContactModal = ->
                $rootScope.$broadcast 'openContactModal'

            $scope.openAccountModal = ->
                $rootScope.$broadcast 'dashboard.openAccountModal'

            $scope.$on 'newContact', (e, contact) ->
                $scope.form.contacts.push contact

            $scope.cancel = ->
                $modalInstance.close()

            $scope.submitForm = ->
                $scope.errors = {}

                fields = ['deal', 'advertiser', 'agency', 'publisher', 'contacts', 'date', 'comment']
                if $scope.showReminderForm
                    fields.push('reminderName', 'reminderDate', 'reminderComment')

                fields.forEach (key) ->
                    field = $scope.form[key]
                    switch key
                        when 'deal'
                            if !field && !$scope.form.advertiser && !$scope.form.agency && !$scope.form.publisher
                                return $scope.errors[key] = 'At least one is required'
                            if field && typeof field != 'object'
                                return $scope.errors[key] = 'Record doesn\'t exist'
                        when 'advertiser'
                            if !field && !$scope.form.deal && !$scope.form.agency && !$scope.form.publisher
                                return $scope.errors[key] = ' '
                            if field && typeof field != 'object'
                                return $scope.errors[key] = 'Record doesn\'t exist'
                        when 'agency'
                            if !field && !$scope.form.advertiser && !$scope.form.deal && !$scope.form.publisher
                                return $scope.errors[key] = ' '
                            if field && typeof field != 'object'
                                return $scope.errors[key] = 'Record doesn\'t exist'
                        when 'publisher'
                            if !field && !$scope.form.deal && !$scope.form.advertiser && !$scope.form.agency
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

                $scope.customFieldNames.forEach (item) ->
                  if item.is_required && (!$scope.form.activity_custom_field_obj || !$scope.form.activity_custom_field_obj[item.field_type + item.field_index])
                    $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

                if Object.keys($scope.errors).length > 0 then return

                activityData =
                    activity_type_id: $scope.selectedType.id
                    activity_type_name: $scope.selectedType.name
                    comment: $scope.form.comment
                    happened_at: $scope.form.date
                    custom_field_attributes: $scope.form.activity_custom_field_obj
                    timed: false
                if $scope.form.time && $scope.form.time.getTime
                    activityData.timed = true
                    activityData.happened_at.setHours($scope.form.time.getHours(), $scope.form.time.getMinutes(), 0)
                if $scope.form.deal
                    activityData.deal_id = $scope.form.deal.id
                    activityData.client_id = $scope.form.deal.advertiser_id
                    activityData.agency_id = $scope.form.deal.agency_id
                else
                    activityData.deal_id = null
                    activityData.client_id = $scope.form.advertiser && $scope.form.advertiser.id || null
                    activityData.agency_id = $scope.form.agency && $scope.form.agency.id || null
                if $scope.form.publisher
                    activityData.publisher_id = $scope.form.publisher.id
                    activityData.client_id = activityData.client_id || $scope.form.publisher.client_id

                if $scope.form.contacts.length
                    $scope.form.contacts = $scope.form.contacts.map (c) ->
                        if typeof c is 'object' then c.id else c
                if options && options.type == 'gmail' && $scope.form.guests && $scope.form.guests.length
                    $scope.form.guests = _.chain $scope.form.guests
                                          .reject (guest) -> !_.contains $scope.form.contacts, guest.id
                                          .map (guest) -> _.omit guest, ['id', 'isGuest']
                                          .value()
                if activity
                    updateActivity(activity.id, activityData, $scope.form.contacts, $scope.form.guests)
                else
                    createActivity(activityData, $scope.form.contacts, $scope.form.guests)


            createActivity = (activity, contacts, guests) ->
                Activity.create({
                    activity
                    contacts
                    guests
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
                            $modalInstance.close(activity)
                            $rootScope.$broadcast 'dashboard.updateBlocks', ['activities', 'reminders']
                        , (err) ->
                            console.log(err)
                    else
                        $modalInstance.close(activity)
                        if options
                            $rootScope.$broadcast 'updated_activities'
                        else
                            $rootScope.$broadcast 'dashboard.updateBlocks', ['activities']

            updateActivity = (id, activity, contacts, guests) ->
                Activity.update({
                    id
                    activity
                    contacts
                    guests
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
                                    $modalInstance.close(activity)
                                    $rootScope.$broadcast 'dashboard.updateBlocks', ['activities', 'reminders']
                                , (err) ->
                                    console.log(err)
                        else
                            Reminder.create(reminder: $scope.reminder).then (reminder) ->
                                $modalInstance.close(activity)
                                $rootScope.$broadcast 'dashboard.updateBlocks', ['activities', 'reminders']
                            , (err) ->
                                console.log(err)
                    else
                        $modalInstance.close(activity)
                        $rootScope.$broadcast 'dashboard.updateBlocks', ['activities']
]
