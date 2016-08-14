@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', '$location', '$anchorScroll', 'Deal', 'Product', 'DealProduct', 'DealMember', 'Stage', 'User', 'Field', 'Activity', 'Contact', 'ActivityType',
($scope, $routeParams, $modal, $filter, $location, $anchorScroll, Deal, Product, DealProduct, DealMember, Stage, User, Field, Activity, Contact, ActivityType) ->

  $scope.showMeridian = true
  $scope.feedName = 'Deal Updates'
  $scope.types = []
  $scope.contacts = []
  $scope.errors = {}

  $scope.init = ->
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    Deal.get($routeParams.id).then (deal) ->
      $scope.setCurrentDeal(deal)
      $scope.activities = deal.activities

    $scope.anchors = [{name: 'campaign', id: 'campaign'},
                      {name: 'activities', id: 'activities'},
                      {name: 'team & split', id: 'teamsplit'},
                      {name: 'documents', id: 'documents'},
                      {name: 'additional info', id: 'info'}]

    $scope.initActivity()

  $scope.initActivity = ->
    $scope.activity = {}
    $scope.activeTab = {}
    $scope.selectedObj = {}
    $scope.selectedObj.deal = true
    $scope.selected = {}
    $scope.populateContact = false
    now = new Date
    ActivityType.all().then (activityTypes) ->
      $scope.types = activityTypes
      $scope.activeType = activityTypes[0]
      _.each activityTypes, (type) ->
        $scope.selected[type.name] = {}
        $scope.selected[type.name].date = now
        $scope.selected[type.name].contacts = []

  $scope.setCurrentDeal = (deal) ->
    _.each deal.members, (member) ->
      Field.defaults(member, 'Client').then (fields) ->
        member.role = Field.field(member, 'Member Role')
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      deal.close_reason = Field.field(deal, 'Close Reason')
      $scope.currentDeal = deal
    Contact.$resource.query().$promise.then (contacts) ->
      $scope.contacts = contacts
#    Contact.allForClient deal.advertiser_id, (contacts) ->
#      $scope.contacts = contacts

  $scope.getStages = ->
    Stage.query().$promise.then (stages) ->
      $scope.stages = stages

  $scope.toggleProductForm = ->
    $scope.resetDealProduct()
    for month in $scope.currentDeal.months
      $scope.deal_product.months.push({ value: '' })
    $scope.showProductForm = !$scope.showProductForm
    Product.all().then (products) ->
      $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

  $scope.$watch 'deal_product.total_budget', ->
    budget = $scope.deal_product.total_budget / $scope.currentDeal.days
    _.each $scope.deal_product.months, (month, index) ->
      month.value = $filter('currency')($scope.currentDeal.days_per_month[index] * budget, '$', 0)

  $scope.addProduct = ->
    DealProduct.create($scope.deal_product).then (deal) ->
      $scope.showProductForm = false
      $scope.currentDeal = deal

  $scope.resetDealProduct = ->
    $scope.deal_product = {
      deal_id: $routeParams.id
      months: []
    }

  $scope.showLinkExistingUser = ->
    User.query().$promise.then (users) ->
      $scope.users = $filter('notIn')(users, $scope.currentDeal.members, 'user_id')

  $scope.linkExistingUser = (item) ->
    $scope.userToLink = undefined
    DealMember.create(deal_id: $scope.currentDeal.id, deal_member: { user_id: item.id, share: 0, values: [] }).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDeal = ->
    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealStage = (currentDeal) ->
    if currentDeal != null
      Stage.get(id: currentDeal.stage_id).$promise.then (stage) ->
        if !stage.open
          $scope.showModal(currentDeal)
        else
          Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then (deal) ->
            if currentDeal.close_reason.option == undefined
              $scope.setCurrentDeal(deal)
            else
              $scope.init()

  $scope.updateDealProduct = (data) ->
    DealProduct.update(id: data.id, deal_id: $scope.currentDeal.id, deal_product: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealProductTotalBudget = (product_id, total_budget) ->
    DealProduct.update_total_budget(deal_id: $scope.currentDeal.id, product_id: product_id, total_budget: total_budget).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.updateDealMember = (data) ->
    DealMember.update(id: data.id, deal_id: $scope.currentDeal.id, deal_member: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.deleteMember = (member) ->
    if confirm('Are you sure you want to delete "' +  member.name + '"?')
      DealMember.delete(id: member.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.deleteProduct = (product) ->
    if confirm('Are you sure you want to delete "' +  product.name + '"?')
      DealProduct.delete(id: product.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.isActive = (id) ->
    $scope.activeAnchor == id

  $scope.scrollTo = (id) ->
    $scope.activeAnchor = id
    $anchorScroll(id)

  $scope.cancelAddProduct = ->
    $scope.showProductForm = !$scope.showProductForm

  $scope.showModal = (currentDeal) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_close_form.html'
      size: 'lg'
      controller: 'DealsCloseController'
      backdrop: 'static'
      keyboard: false
      resolve:
        currentDeal: ->
          currentDeal

  $scope.$on 'updated_deal', ->
    $scope.init()

  $scope.$on 'updated_activities', ->
    $scope.init()

  $scope.init()

  $scope.setActiveTab = (tab) ->
    $scope.activeTab = tab

  $scope.setActiveType = (type) ->
    $scope.activeType = type

  $scope.submitForm = (form) ->
    $scope.errors = {}
    $scope.buttonDisabled = true
    if form.$valid
      if !$scope.activity.comment
        $scope.buttonDisabled = false
        $scope.errors['Comment'] = ["can't be blank."]
      if !($scope.activeType && $scope.activeType.id)
        $scope.buttonDisabled = false
        $scope.errors['Activity Type'] = ["can't be blank."]
      data = $scope.selected[$scope.activeType.name]
      if !data.contacts || data.contacts.length == 0
        $scope.buttonDisabled = false
        $scope.errors['Contacts'] = ["can't be blank."]
      if !$scope.buttonDisabled
        return
      form.submitted = true
      $scope.activity.deal_id = $scope.currentDeal.id
      $scope.activity.client_id = $scope.currentDeal.advertiser_id
      $scope.activity.activity_type_id = $scope.activeType.id
      $scope.activity.activity_type_name = $scope.activeType.name
      contact_date = new Date(data.date)
      if data.time != undefined
        contact_time = new Date(data.time)
        contact_date.setHours(contact_time.getHours(), contact_time.getMinutes(), 0, 0)
        $scope.activity.timed = true
      $scope.activity.happened_at = contact_date
      Activity.create({ activity: $scope.activity, contacts: data.contacts }, (response) ->
        angular.forEach response.data.errors, (errors, key) ->
          form[key].$dirty = true
          form[key].$setValidity('server', false)
          $scope.buttonDisabled = false
      ).then (activity) ->
        $scope.buttonDisabled = false
        $scope.init()

  $scope.createNewContactModal = ->
    $scope.populateContact = true
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'lg'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {}

  $scope.showActivityEditModal = (activity) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_form.html'
      size: 'lg'
      controller: 'ActivitiesEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        activity: ->
          activity
        types: ->
          $scope.types
        contacts: ->
          $scope.contacts
        types: ->
          $scope.types

  $scope.cancelActivity = ->
    $scope.initActivity()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
#      $scope.contacts.push contact
      $scope.selected[$scope.activeType.name].contacts.push contact
      $scope.populateContact = false

  $scope.deleteActivity = (activity) ->
    if confirm('Are you sure you want to delete the activity?')
      Activity.delete activity, ->
        $scope.$emit('updated_activities')
  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)
]
