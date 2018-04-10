@app.controller 'ContactsController',
    ['$scope', '$rootScope', '$window', '$modal', '$routeParams', '$location', '$sce', '$http', '$httpParamSerializer', 'Contact', 'Field', 'Activity', 'ActivityType', 'Reminder',  'ContactsFilter'
    ( $scope,   $rootScope,   $window,   $modal,   $routeParams,   $location,   $sce,   $http,   $httpParamSerializer,   Contact,   Field,   Activity,   ActivityType,   Reminder,    ContactsFilter) ->

            $scope.contacts = []
            $scope.feedName = 'Updates'
            $scope.page = 1
            $scope.contactsPerPage = 20
            $scope.query = ""
            $scope.showMeridian = true
            $scope.isLoading = false
            $scope.allContactsLoaded = false
            $scope.types = []
            $scope.errors = {}
            $scope.itemType = 'Contact'
            $scope.switches = [
                {name: 'My Contacts', param: 'my_contacts'}
                {name: 'My Team\'s Contacts', param: 'team'}
                {name: 'All Contacts', param: ''}
            ]

            $scope.teamFilter = (value) ->
                if value then ContactsFilter.teamFilter = value else ContactsFilter.teamFilter

            if !$scope.teamFilter() then $scope.teamFilter $scope.switches[0]

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
                        filter.start_date = s.date.startDate.toDate()
                        filter.end_date = s.date.endDate.toDate()
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
#                    this.apply(true)
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

            $scope.getContacts = (next) ->
                $scope.isLoading = true
                if !next then $scope.page = 1
                params = {
                    page: $scope.page,
                    filter: $scope.teamFilter().param,
                    per: $scope.contactsPerPage
                }
                params = _.extend params, $scope.filter.get()
                if $scope.query.trim().length
                    params.q = $scope.query.trim()
                Contact.all1(params).then (contacts) ->
                    $scope.allContactsLoaded = !contacts || contacts.length < $scope.contactsPerPage
                    if $scope.page++ > 1
                        $scope.contacts = $scope.contacts.concat(contacts)
                    else
                        $scope.contacts = contacts
                    $scope.isLoading = false

            $scope.loadMoreContacts = ->
                if !$scope.allContactsLoaded then $scope.getContacts(true)

            $scope.showModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/contact_form.html'
                    size: 'md'
                    controller: 'ContactsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        contact: -> {}
                        options: -> {}

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
                $scope.teamFilter swch
                $scope.init();

            $scope.export = ->
                params = {
                    filter: $scope.teamFilter().param,
                }
                params = _.extend params, $scope.filter.get()
                if $scope.query.trim().length
                    params.name = $scope.query.trim()
                $window.open Contact.exportUrl + '?' + $httpParamSerializer params
                return

            $scope.$on 'updated_contacts', ->
                $scope.init()

            $scope.$on 'updated_activities', ->
                $scope.init()

            $scope.$on 'newContact', (event, contact) ->
                $location.path('/contacts/' + contact.id)

            $scope.init()

    ]
