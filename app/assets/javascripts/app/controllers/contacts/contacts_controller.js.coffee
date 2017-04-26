@app.controller 'ContactsController',
    ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$sce', '$http', 'Contact', 'Field', 'Activity', 'ActivityType', 'Reminder',  'ContactsFilter'
    ( $scope,   $rootScope,   $modal,   $routeParams,   $location,   $sce,   $http,   Contact,   Field,   Activity,   ActivityType,   Reminder,    ContactsFilter) ->
            $scope.contacts = []
            $scope.feedName = 'Updates'
            $scope.page = 1
            $scope.query = ""
            $scope.showMeridian = true
            $scope.types = []
            $scope.errors = {}
            $scope.itemType = 'Contact'
            $scope.switches = [
                {name: 'My Contacts', param: 'my_contacts'}
                {name: 'My Team\'s Contacts', param: 'team'}
                {name: 'All Contacts', param: ''}
            ]
            $scope.selectedSwitch = $scope.switches[0]

            $scope.filter =
                workPlaces: []
                jobLevels: []
                cities: []
                isOpen: false
                search: ''
                selected: ContactsFilter.selected
                datePicker:
                    date:
                        startDate: null
                        endDate: null
                    apply: ->
                        _this = $scope.filter.datePicker
                        if (_this.date.startDate && _this.date.endDate)
                            $scope.filter.selected.date = _this.date
                apply: (reset) ->
                    s = this.selected
                    filter = {}
                    filter.workplace = s.workPlace if s.workPlace
                    filter.job_level = s.jobLevel if s.jobLevel
                    filter.city = s.city if s.city
                    if s.date.startDate && s.date.endDate
                        filter.srart_date = s.date.startDate.toDate()
                        filter.end_date = s.date.endDate.toDate()
                    $scope.getContacts filter
#                    $scope.contacts = $scope.allDeals.filter (contact) ->
#                        if selected.owner && contact.members.indexOf(selected.owner) is -1
#                            return false
#                        if selected.advertiser && (!contact.advertiser || contact.advertiser.id != selected.advertiser.id)
#                            return false
#                        if selected.agency && (!contact.agency || contact.agency.id != selected.agency.id)
#                            return false
#                        contact
                    if !reset then this.isOpen = false
                searching: (item) ->
                    if !item then return false
                    if item.name
                        return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
                    else
                        return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
                reset: (key) ->
                    ContactsFilter.reset(key)
                resetAll: ->
                    ContactsFilter.resetAll()
                    this.apply(true)
                getDateValue: ->
                    date = this.selected.date
                    if date.startDate && date.endDate
                        return """#{date.startDate.format('MMMM D, YYYY')} -\n#{date.endDate.format('MMMM D, YYYY')}"""
                    return 'Time period'
                select: (key, value) ->
                    ContactsFilter.select(key, value)
                onDropdownToggle: ->
                    this.search = ''
                open: ->
                    this.isOpen = true
                close: ->
                    this.isOpen = false

            $scope.activityReminderInit = ->
                $scope.activityReminder = {
                    name: '',
                    comment: '',
                    completed: false,
                    remind_on: '',
                    remindable_id: 0,
                    remindable_type: 'Activity' # "Activity", "Client", "Contact", "Deal"
                    _date: new Date(),
                    _time: new Date()
                }

                $scope.activityReminderOptions = {
                    errors: {},
                    showMeridian: true
                }

            $scope.initActivity = (contact, activityTypes) ->
                $scope.activity = {}
                contact.activity = {}
                contact.activeTab = {}
                contact.selected = {}
                contact.populateContact = false
                contact.activeType = activityTypes[0]
                now = new Date
                _.each activityTypes, (type) ->
                    contact.selected[type.name] = {}
                    contact.selected[type.name].date = now

                $scope.activityReminderInit()

            $scope.init = ->
                $scope.getContacts()
                ActivityType.all().then (activityTypes) ->
                    $scope.types = activityTypes
                Field.defaults({}, 'Client').then (fields) ->
                    client_types = Field.findClientTypes(fields)
                    $scope.setClientTypes(client_types)
                Contact.metadata().$promise.then (metadata) ->
                    console.log metadata
                    $scope.filter.workPlaces = metadata.workplaces
                    $scope.filter.jobLevels = metadata.job_levels
                    $scope.filter.cities = metadata.cities

            $scope.setClientTypes = (client_types) ->
                client_types.options.forEach (option) ->
                    $scope[option.name] = option.id

#            $scope.getHtml = (html) ->
#                return $sce.trustAsHtml(html)


            $scope.$watch 'query', (oldValue, newValue) ->
                if oldValue != newValue then $scope.getContacts()

            $scope.getContacts = (extraFilter) ->
                $scope.isLoading = true
                params = {
                    page: $scope.page,
                    filter: $scope.selectedSwitch.param,
                    per: 20
                }
                params = _.extend params, extraFilter if extraFilter
                if $scope.query.trim().length
                    params.name = $scope.query.trim()
                Contact.all1(params).then (contacts) ->
                    console.log contacts[0]
                    console.log contacts.length
                    if $scope.page > 1
                        $scope.contacts = $scope.contacts.concat(contacts)
                    else
                        $scope.contacts = contacts
#                        if contacts.length > 0
#                            if $scope.currentContact
#                                Contact.set($scope.currentContact.id || contacts[0].id)
#                            else
#                                Contact.set(contacts[0].id)
#                        else
#                            $scope.currentContact = null

#                    _.each $scope.contacts, (contact) ->
#                        $scope.initActivity(contact, $scope.types)
#                        $scope.initReminder()
                    $scope.isLoading = false

            # Prevent multiple extraneous calls to the server as user inputs search term
            #  searchTimeout = null;
            #  $scope.searchContacts = (query) ->
            #    $scope.page = 1
            #    if searchTimeout
            #      clearTimeout(searchTimeout)
            #      searchTimeout = null
            #    searchTimeout = setTimeout(
            #      -> $scope.getContacts()
            #      250
            #    )

            $scope.isLoading = false
            $scope.loadMoreContacts = ->
                if $scope.contacts && $scope.contacts.length < Contact.totalCount
                    $scope.page = $scope.page + 1
                    $scope.getContacts()

            $scope.showModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/contact_form.html'
                    size: 'md'
                    controller: 'ContactsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        contact: ->
                            {}

            $scope.showEditModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/contact_form.html'
                    size: 'md'
                    controller: 'ContactsEditController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        contact: ->
                            undefined

#            $scope.showNewActivityModal = ->
#                $scope.modalInstance = $modal.open
#                    templateUrl: 'modals/activity_new_form.html'
#                    size: 'md'
#                    controller: 'ActivityNewController'
#                    backdrop: 'static'
#                    keyboard: false
#                    resolve:
#                        activity: ->
#                            null
#                        options: ->
#                            type: 'contact'
#                            data: $scope.currentContact
#                            isAdvertiser: $scope.currentContact.primary_client_json.client_type_id == $scope.Advertiser
#
#            $scope.showActivityEditModal = (activity) ->
#                $scope.modalInstance = $modal.open
#                    templateUrl: 'modals/activity_new_form.html'
#                    size: 'md'
#                    controller: 'ActivityNewController'
#                    backdrop: 'static'
#                    keyboard: false
#                    resolve:
#                        activity: ->
#                            activity
#                        options: ->
#                            type: 'contact'
#                            data: $scope.currentContact
#                            isAdvertiser: $scope.currentContact.primary_client_json.client_type_id == $scope.Advertiser
#
#            $scope.showEmailsModal = (activity) ->
#                $scope.modalInstance = $modal.open
#                    templateUrl: 'modals/activity_emails.html'
#                    size: 'lg'
#                    controller: 'ActivityEmailsController'
#                    backdrop: 'static'
#                    keyboard: false
#                    resolve:
#                        activity: ->
#                            activity

            $scope.delete = ->
                if confirm('Are you sure you want to delete "' + $scope.currentContact.name + '"?')
                    Contact.delete({id: $scope.currentContact.id}, ((res) ->
                        i = 0
                        arrayLength = $scope.contacts.length
                        while i < arrayLength
                            if($scope.currentContact && $scope.contacts[i].id == $scope.currentContact.id )
                                $scope.contacts.splice(i, 1)
                                if($scope.contacts && $scope.contacts.length)
                                    $scope.currentContact = $scope.contacts[0]
                                else
                                    $scope.init()
                                break
                            i++
                    ), (err) ->
                        console.log (err)
                    )

#            $scope.deleteActivity = (activity) ->
#                if confirm('Are you sure you want to delete the activity?')
#                    Activity.delete activity, ->
#                        $scope.$emit('updated_current_contact')

#            $scope.showContact = (contact) ->
#                Contact.set(contact.id) if contact
#                $scope.initReminder()
#
#            $scope.loadActivities = (contact_id) ->
#                Activity.all(contact_id: contact_id).then (activities) ->
#                    $scope.currentActivities = activities
#                    $scope.activities = activities

            $scope.switchContacts = (swch) ->
                $scope.selectedSwitch = swch
                $scope.init();

            $scope.$on 'updated_current_contact', ->
                $scope.currentContact = Contact.get()
                if $scope.currentContact && $scope.currentContact.id
                    $scope.loadActivities($scope.currentContact.id)

            $scope.$on 'updated_contacts', ->
                $scope.init()

            $scope.$on 'updated_activities', ->
                $scope.init()

            $scope.init()

#            $scope.submitForm = () ->
#                $scope.errors = {}
#                $scope.buttonDisabled = true
#                if !$scope.currentContact.activity.comment
#                    $scope.buttonDisabled = false
#                    $scope.errors['Comment'] = ["can't be blank."]
#                if !$scope.currentContact.activity.activeTab
#                    $scope.buttonDisabled = false
#                    $scope.errors['Activity Type'] = ["can't be blank."]
#                if $scope.actRemColl
#                    if !($scope.activityReminder && $scope.activityReminder.name)
#                        $scope.buttonDisabled = false
#                        $scope.errors['Activity Reminder Name'] = ["can't be blank."]
#                    if !($scope.activityReminder && $scope.activityReminder._date)
#                        $scope.buttonDisabled = false
#                        $scope.errors['Activity Reminder Date'] = ["can't be blank."]
#                    if !($scope.activityReminder && $scope.activityReminder._time)
#                        $scope.buttonDisabled = false
#                        $scope.errors['Activity Reminder Time'] = ["can't be blank."]
#                if !$scope.buttonDisabled
#                    return
#
#                if $scope.currentContact.primary_client_json.client_type_id == $scope.Advertiser
#                    $scope.activity.client_id = $scope.currentContact.client_id
#                    $scope.activity.agency_id = null
#                else
#                    $scope.activity.client_id = null
#                    $scope.activity.agency_id = $scope.currentContact.client_id
#
#                $scope.activity.comment = $scope.currentContact.activity.comment
#                $scope.activity.activity_type_id = $scope.currentContact.activeType.id
#                $scope.activity.activity_type_name = $scope.currentContact.activeType.name
#                contactDate = new Date($scope.currentContact.selected[$scope.currentContact.activeType.name].date)
#                if $scope.currentContact.selected[$scope.currentContact.activeType.name].time != undefined
#                    contactTime = new Date($scope.currentContact.selected[$scope.currentContact.activeType.name].time)
#                    contactDate.setHours(contactTime.getHours(), contactTime.getMinutes(), 0, 0)
#                    $scope.activity.timed = true
#                $scope.activity.happened_at = contactDate
#                Activity.create({activity: $scope.activity, contacts: [$scope.currentContact.id]}, (response) ->
#                    $scope.buttonDisabled = false
#                ).then (activity) ->
#                    if (activity && activity.id && $scope.actRemColl)
#                        reminder_date = new Date($scope.activityReminder._date)
#                        $scope.activityReminder.remindable_id = activity.id
#                        if $scope.activityReminder._time != undefined
#                            reminder_time = new Date($scope.activityReminder._time)
#                            reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
#                        $scope.activityReminder.remind_on = reminder_date
#                        Reminder.create(reminder: $scope.activityReminder)
#                    #        .then (reminder) ->
#                    #        , (err) ->
#
#                    $scope.buttonDisabled = false
#                    $scope.init()

#            $scope.cancelActivity = (contact) ->
#                $scope.initActivity(contact, $scope.types)
#
#            $scope.getType = (type) ->
#                _.findWhere($scope.types, name: type)

#            $scope.concatAddress = (address) ->
#                row = []
#                if address
#                    if address.city then row.push address.city
#                    if address.state then row.push address.state
#                    if address.zip then row.push address.zip
#                    if address.country then row.push address.country
#                row.join(', ')

#            $scope.initReminder = ->
#                $scope.showReminder = false;
#
#                if ($scope.currentContact && $scope.currentContact.id)
#
#                    $scope.reminder = {
#                        name: '',
#                        comment: '',
#                        completed: false,
#                        remind_on: '',
#                        remindable_id: $scope.currentContact.id,
#                        remindable_type: 'Contact' # "Activity", "Client", "Contact", "Deal"
#                        _date: new Date(),
#                        _time: new Date()
#                    }
#
#                    $scope.reminderOptions = {
#                        editMode: false,
#                        errors: {},
#                        buttonDisabled: false,
#                        showMeridian: true
#                    }
#
#                #    Reminder.get($scope.reminder.remindable_id, $scope.reminder.remindable_type).then (reminder) ->
#                $http.get('/api/remindable/' + $scope.reminder.remindable_id + '/' + $scope.reminder.remindable_type).then (respond) ->
#                    if (respond && respond.data && respond.data.length)
#                        _.each respond.data, (reminder) ->
#                            if (reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
#                                $scope.reminder.id = reminder.id
#                                $scope.reminder.name = reminder.name
#                                $scope.reminder.comment = reminder.comment
#                                $scope.reminder.completed = reminder.completed
#                                $scope.reminder._date = new Date(reminder.remind_on)
#                                $scope.reminder._time = new Date(reminder.remind_on)
#                                $scope.reminderOptions.editMode = true

#            $scope.submitReminderForm = () ->
#                $scope.reminderOptions.errors = {}
#                $scope.reminderOptions.buttonDisabled = true
#                if !($scope.reminder && $scope.reminder.name)
#                    $scope.reminderOptions.buttonDisabled = false
#                    $scope.reminderOptions.errors['Name'] = "can't be blank."
#                if !($scope.reminder && $scope.reminder._date)
#                    $scope.reminderOptions.buttonDisabled = false
#                    $scope.reminderOptions.errors['Date'] = "can't be blank."
#                if !($scope.reminder && $scope.reminder._time)
#                    $scope.reminderOptions.buttonDisabled = false
#                    $scope.reminderOptions.errors['Time'] = "can't be blank."
#                if !$scope.reminderOptions.buttonDisabled
#                    return
#
#                reminder_date = new Date($scope.reminder._date)
#                if $scope.reminder._time != undefined
#                    reminder_time = new Date($scope.reminder._time)
#                    reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
#                $scope.reminder.remind_on = reminder_date
#                if ($scope.reminderOptions.editMode)
#                    Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder).then (reminder) ->
#                        $scope.reminderOptions.buttonDisabled = false
#                        $scope.showReminder = false;
#                        $scope.reminder = reminder
#                        $scope.reminder._date = new Date($scope.reminder.remind_on)
#                        $scope.reminder._time = new Date($scope.reminder.remind_on)
#                        $scope.reminderOptions.editMode = true
#                    , (err) ->
#                        $scope.reminderOptions.buttonDisabled = false
#                else
#                    Reminder.create(reminder: $scope.reminder).then (reminder) ->
#                        $scope.reminderOptions.buttonDisabled = false
#                        $scope.showReminder = false;
#                        $scope.reminder = reminder
#                        $scope.reminder._date = new Date($scope.reminder.remind_on)
#                        $scope.reminder._time = new Date($scope.reminder.remind_on)
#                        $scope.reminderOptions.editMode = true
#                    , (err) ->
#                        $scope.reminderOptions.buttonDisabled = false

    ]
