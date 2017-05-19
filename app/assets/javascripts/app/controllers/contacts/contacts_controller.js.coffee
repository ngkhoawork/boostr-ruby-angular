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
                get: ->
                    s = this.selected
                    filter = {}
                    filter.workplace = s.workPlace if s.workPlace
                    filter.job_level = s.jobLevel if s.jobLevel
                    filter.city = s.city if s.city
                    filter.country = s.country if s.country
                    if s.date.startDate && s.date.endDate
                        filter.start_date = s.date.startDate.format('YYYY-MM-DD') + 'T00:00:00.000Z'
                        filter.end_date = s.date.endDate.format('YYYY-MM-DD') + 'T23:59:59.999Z'
                    filter
                apply: (reset) ->
                    $scope.getContacts()
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
                    $scope.filter.workPlaces = metadata.workplaces
                    $scope.filter.jobLevels = metadata.job_levels
                    $scope.filter.cities = metadata.cities
                    $scope.filter.countries = metadata.countries

            $scope.setClientTypes = (client_types) ->
                client_types.options.forEach (option) ->
                    $scope[option.name] = option.id


            $scope.$watch 'query', (oldValue, newValue) ->
                if oldValue != newValue
                    $scope.page = 1
                    $scope.getContacts()

            $scope.getContacts = ->
                $scope.isLoading = true
                params = {
                    page: $scope.page,
                    filter: $scope.selectedSwitch.param,
                    per: 20
                }
                params = _.extend params, $scope.filter.get()
                if $scope.query.trim().length
                    params.name = $scope.query.trim()
                Contact.all1(params).then (contacts) ->
                    if $scope.page > 1
                        $scope.contacts = $scope.contacts.concat(contacts)
                    else
                        $scope.contacts = contacts
                    $scope.isLoading = false

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


            $scope.switchContacts = (swch) ->
                $scope.selectedSwitch = swch
                $scope.init();

            $scope.$on 'updated_contacts', ->
                $scope.init()

            $scope.$on 'updated_activities', ->
                $scope.init()

            $scope.init()

    ]
