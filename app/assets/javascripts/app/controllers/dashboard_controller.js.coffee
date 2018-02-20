@app.controller 'DashboardController',
    ['$scope', '$rootScope', '$document', '$http', '$modal', '$sce', 'Dashboard', 'Deal', 'Client', 'Field', 'Contact', 'Activity', 'ActivityType', 'Reminder', 'Stage', 'CurrentUser', 'PacingAlerts'
    ( $scope,   $rootScope,   $document,   $http,   $modal,   $sce,   Dashboard,   Deal,   Client,   Field,   Contact,   Activity,   ActivityType,   Reminder,   Stage,   CurrentUser,   PacingAlerts ) ->

            $scope.progressPercentage = 10
            $scope.showMeridian = true
            $scope.feedName = 'Activity Updates'
            $scope.moreSize = 10;
            $scope.types = []
            $scope.contactActionLog = []
            $scope.loadMoreActivitiesText = "Load More"
            $scope.loadingMoreActivities = false
            $scope.contactSearch = ""
            $scope.activitySwitch = 'past'

            $scope.pacingAlertsFilters = [
              { name: 'My Lines', value: 'my', order: 0 }
              { name: 'My Team\'s Lines', value: 'teammates', order: 1 }
              { name: 'All Lines', value: 'all', order: 2 }
            ]

            $scope.currentPacingAlertsFilter = { name: 'My Lines', value: 'my', order: 2 }

            $scope.setPacingAlertsFilter = (filter) ->
              $scope.currentPacingAlertsFilter = filter
              $scope.pacingAlertsIsLoading = true
              getPacingAlerts()

            $scope.setActivitySwitch = (val) ->
                $scope.activitySwitch = val
                $scope.activitiesInit()

            $scope.showSpinners = (reminder) ->
                reminder.showSpinners = true

            $scope.init = ->
                $scope.currentPage = 0;
                $scope.activity = {}
                $scope.activeTab = {}
                $scope.selectedObj = {}
                $scope.selectedObj.deal = 1
                $scope.selectedObj.showAgency = false
                $scope.selectedObj.showAgencySelector = false
                $scope.selected = {}
                $scope.populateContact = false
                $scope.contacts = []
                $scope.errors = {}
                $scope.getStages()

                $scope.actRemColl = false;

                $scope.reminder = {
                    name: '',
                    comment: '',
                    completed: false,
                    remind_on: '',
                    remindable_id: 0,
                    remindable_type: 'Activity' # "Activity", "Client", "Contact", "Deal"
                    _date: new Date(),
                    _time: new Date(),
                    showSpinners: false
                }

                $scope.reminderOptions = {
                    errors: {},
                    showMeridian: true
                }

                now = new Date
                ActivityType.all().then (activityTypes) ->
                    $scope.types = activityTypes
                    $scope.activeType = activityTypes[0]
                    _.each activityTypes, (type) ->
                        $scope.selected[type.name] = {}
                        $scope.selected[type.name].date = now
                        $scope.selected[type.name].contacts = []

                $scope.activitiesInit()

                Contact.all1(unassigned: "yes").then (contacts) ->
                    $scope.unassignedContacts = contacts
                    $scope.contactNotification = {}
                    _.each $scope.unassignedContacts, (contact) ->
                        $scope.contactNotification[contact.id] = ""

                Contact.query().$promise.then (contacts) ->
                    $scope.contacts = contacts

                getDashboardData()
                getPacingAlerts()
                getValidations()

            $scope.$on 'dashboard.updateBlocks', (e, blocks) ->
                blocks.forEach (name) -> $scope[name + 'Init']()

            $scope.$on 'openContactModal', ->
                $scope.createNewContactModal()

            $scope.$on 'dashboard.openAccountModal', ->
                $scope.showNewAccountModal()

            getDashboardData = ->
                $scope.dashboardIsLoading = true

                Dashboard.get().then (data) ->
                    $scope.dashboard = data
                    $scope.dashboardIsLoading = false
                , (error) ->
                    $scope.dashboard = null
                    $scope.dashboardIsLoading = false

            getPacingAlerts = ->
                $scope.pacingAlertsIsLoading = true

                PacingAlerts.get(io_owner: $scope.currentPacingAlertsFilter.value).then (data) ->
                    $scope.pacingAlerts = data
                    $scope.pacingAlertsIsLoading = false
                , (error) ->
                    $scope.pacingAlerts = null
                    $scope.pacingAlertsIsLoading = false

            getValidations = ->
              Validation.query(factor: 'Require Won Reason').$promise.then (data) ->
                $scope.won_reason_required = data && data[0]

            getActivityDateRange = ->
                switch $scope.activitySwitch
                     when 'past'
                         start_date: moment('2015-01-01')
                         end_date: moment()
                     when 'future'
                         start_date: moment()
                         end_date: moment().add(5, 'years')
                     else
                         {}

            $scope.activitiesInit = ->
                params = {page: 1, filter: "client"}
                params.order = 'asc' if $scope.activitySwitch == 'future'
                _.extend params, getActivityDateRange()
                Activity.all(params).then (activities) ->
                    $scope.activities = activities
                    if activities.length == 10
                        $scope.hasMoreActivities = true
                    $scope.nextActivitiesPage = 2

            $scope.loadMoreActivities = ->
                if $scope.loadingMoreActivities == false
                    $scope.loadingMoreActivities = true
                    $scope.loadMoreActivitiesText = "Loading ..."
                    params = {page: $scope.nextActivitiesPage, filter: "client"}
                    params.order = 'asc' if $scope.activitySwitch == 'future'
                    _.extend params, getActivityDateRange()
                    Activity.all(params).then (activities) ->
                        $scope.activities = $scope.activities.concat(activities)
                        if activities.length == 10
                            $scope.hasMoreActivities = true
                        $scope.nextActivitiesPage = $scope.nextActivitiesPage + 1
                        $scope.loadingMoreActivities = false
                        $scope.loadMoreActivitiesText = "Load More"

            $scope.showNewDealModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_form.html'
                    size: 'md'
                    controller: 'DealsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        deal: -> {}
                        options: -> {}

            $scope.showReminderModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/reminder_new_form.html'
                    size: 'md'
                    controller: 'DashboardReminderController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        reminder: -> null

            $scope.showReminderEditModal = (reminder) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/reminder_new_form.html'
                    size: 'md'
                    controller: 'DashboardReminderController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        reminder: ->
                            angular.copy reminder

            $scope.showNewAccountModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/client_form.html'
                    size: 'md'
                    controller: 'AccountsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        client: -> {}
                        options: -> {}

            $scope.showNewActivityModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/activity_new_form.html'
                    size: 'md'
                    controller: 'ActivityNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        activity: ->
                            null
                        options: ->
                            null

            $scope.showActivityEditModal = (activity) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/activity_new_form.html'
                    size: 'md'
                    controller: 'ActivityNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        activity: ->
                            activity
                        options: ->
                            null

            $scope.showAssignContactModal = (contact) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/contact_assign_form.html'
                    size: 'md'
                    controller: 'ContactsAssignController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        contact: ->
                            contact
                .result.then (updated_contact) ->
                    if !updated_contact then return
                    $scope.unassignedContacts = _.map $scope.unassignedContacts, (item) ->
                        if (item.id == updated_contact.id)
                            return updated_contact
                        else
                            return item
                    $scope.contactNotification[updated_contact.id] = "Assigned to " + updated_contact.clients[0].name
                    $scope.contactActionLog.push({
                        previousContact: contact,
                        message: updated_contact.clients[0].name
                    })

            $scope.deleteUnassignedContact = (contact) ->
                if confirm("Are you sure you want to delete contact #{contact.name}?")
                    index = $scope.unassignedContacts.indexOf(contact)
                    contact.$delete {}, ->
                        $scope.unassignedContacts.splice index, 1

            $scope.saveCurrentContact = (contact) ->
                Contact._update(id: contact.id, contact: contact).then (updated_contact) ->
                    $scope.unassignedContacts = _.map $scope.unassignedContacts, (item) ->
                        if (item.id == updated_contact.id)
                            return updated_contact
                        else
                            return item

            $scope.undoAssignContact = (contact) ->
                previousContact = _.find $scope.unassignedContacts, (item) ->
                    return item.id == contact.id
                Contact._update(id: contact.id, contact: contact).then (updated_contact) ->
                    $scope.unassignedContacts = _.map $scope.unassignedContacts, (item) ->
                        if (item.id == updated_contact.id)
                            return updated_contact
                        else
                            return item


                    if updated_contact.clients.length > 0
                        $scope.contactNotification[updated_contact.id] = "Assigned to " + updated_contact.clients[0].name
                        $scope.contactActionLog.push({
                            previousContact: previousContact,
                            message: updated_contact.clients[0].name
                        })
                    else
                        $scope.contactNotification[updated_contact.id] = "Unassigned"
                        $scope.contactActionLog.push({
                            previousContact: previousContact,
                            message: ""
                        })

            $scope.getStages = ->
                Stage.query({active: true, current_team: true}).$promise.then (stages) ->
                    $scope.stages = stages

            $scope.$on 'updated_dashboards', ->
                $scope.init()

            $scope.$on 'updated_activities', ->
                $scope.init()

            $scope.$on 'updated_contacts', ->
                $scope.init()

            $scope.init()

            $scope.setActiveTab = (tab) ->
                $scope.activeTab = tab

            $scope.setActiveType = (type) ->
                $scope.activeType = type


            $scope.createNewContactModal = ->
                $scope.populateContact = true
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/contact_form.html'
                    size: 'md'
                    controller: 'ContactsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        contact: -> {}
                        options: -> {}

            $scope.cancelActivity = ->
                $scope.init()

            $scope.updateDealStage = (currentDeal) ->
                if currentDeal != null
                    Stage.get(id: currentDeal.stage_id).$promise.then (stage) ->
                        if !stage.open && stage.probability == 0
                            $scope.showModal(currentDeal, false)
                        else if !stage.open && stage.probability == 100 && $scope.won_reason_required && $scope.won_reason_required.criterion.value
                            $scope.showModal(currentDeal, true)
                        else
                            Deal.update(id: currentDeal.id, deal: currentDeal).then (deal) ->
                                $scope.init()

            $scope.showModal = (currentDeal, hasWon) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_close_form.html'
                    size: 'md'
                    controller: 'DealsCloseController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        currentDeal: ->
                            currentDeal
                        hasWon: ->
                            hasWon

            $scope.showEmailsModal = (activity) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/activity_emails.html'
                    size: 'email'
                    controller: 'ActivityEmailsController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        activity: ->
                            activity

            $scope.isTextHasTags = (str) -> /<[a-z][\s\S]*>/i.test(str)

            $scope.$on 'updated_deal', ->
                $scope.init()
            $scope.$on 'newContact', (event, contact) ->
                if $scope.populateContact
                    $scope.contacts.push(contact)
                    $scope.selected[$scope.activeType.name].contacts.push(contact.id)
                    $scope.populateContact = false

            $scope.deleteActivity = (activity) ->
                if confirm('Are you sure you want to delete the activity?')
                    Activity.delete activity, ->
                        $scope.$emit('updated_activities')

            $scope.remindersInit = ->
                $scope.remindersOptions = {
                    errors: {},
                    showMeridian: true,
                    editMode: false,
                    buttonDisabled: false
                }

                reminders = []
                completedReminders = []
                $http.get('/api/reminders')
                .then (respond) ->
                    if (respond && respond.data)
                        _.each respond.data, (curReminder) ->
                            curReminder._date = new Date(curReminder.remind_on)
                            curReminder._time = new Date(curReminder.remind_on)
                            curReminder.showSpinners = false
                            now = new Date();
                            yearDiff = curReminder._date.getFullYear() - now.getFullYear()
                            monthDiff = curReminder._date.getMonth() - now.getMonth()
                            dayDiff = curReminder._date.getDate() - now.getDate()
                            if yearDiff > 0
                                curReminder.dateColorClass = 'silver'
                            else if yearDiff < 0
                                curReminder.dateColorClass = 'red'
                            else
                                if monthDiff > 0
                                    curReminder.dateColorClass = 'silver'
                                else if monthDiff < 0
                                    curReminder.dateColorClass = 'red'
                                else
                                    if dayDiff > 1
                                        curReminder.dateColorClass = 'silver'
                                    else if dayDiff == 1
                                        curReminder.dateColorClass = 'yellow'
                                    else
                                        curReminder.dateColorClass = 'red'
                            curReminder.completed = !!curReminder.completed
                            if (curReminder.completed)
                                completedReminders.push(curReminder)
                            else
                                reminders.push(curReminder)

                        $scope.completedReminders = completedReminders
                        $scope.reminders = reminders
                , (err) ->

            $scope.saveCurReminder = (curReminder) ->
                $scope.errors = {}
                #        $scope.buttonDisabled = true
                reminder_date = new Date(curReminder._date)
                if curReminder._time != undefined
                    reminder_time = new Date(curReminder._time)
                    reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
                curReminder.remind_on = reminder_date
                Reminder.update(id: curReminder.id, reminder: curReminder)

            $scope.saveReminder = (curReminder) ->
                $scope.errors = {}
                reminder_date = new Date(curReminder._date)
                if curReminder._time != undefined
                    reminder_time = new Date(curReminder._time)
                    reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
                curReminder.remind_on = reminder_date
                Reminder.update(id: curReminder.id, reminder: curReminder)
                .then (reminder) ->
                    $scope.remindersInit()
                , (err) ->
#                $scope.buttonDisabled = false

            $scope.deleteCurReminder = (curReminder) ->
                $scope.errors = {}
                Reminder.delete(curReminder.id)
                .then (reminder) ->
                    $scope.remindersInit()
                , (err) ->
                    console.log(err)
#                   $scope.buttonDisabled = false

            $scope.remindersInit()

            $scope.getHtml = (html) ->
                return $sce.trustAsHtml(html)

            $scope.getActivityIconUrl = (type) ->
                if type && type.length
                    type = type.toLowerCase().split(' ').join('-')
                    'assets/icons/dashboard/' + type + '.svg'

    ]
