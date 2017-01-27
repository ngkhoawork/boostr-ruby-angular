@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', '$timeout', '$location', '$anchorScroll', '$sce', 'Deal', 'Product', 'DealProduct', 'DealMember', 'DealContact', 'Stage', 'User', 'Field', 'Activity', 'Contact', 'ActivityType', 'Reminder', '$http', 'Transloadit',
($scope, $routeParams, $modal, $filter, $timeout, $location, $anchorScroll, $sce, Deal, Product, DealProduct, DealMember, DealContact, Stage, User, Field, Activity, Contact, ActivityType, Reminder, $http, Transloadit) ->

  $scope.showMeridian = true
  $scope.feedName = 'Deal Updates'
  $scope.types = []
  $scope.contacts = []
  $scope.errors = {}
  $scope.contactSearchText = ""
  $scope.prevStageId = null
  $scope.selectedStageId = null
  $anchorScroll()

  ###*
   * FileUpload
  ###

  $scope.fileToUploadTst = null
  # $scope.progressBarMax = 0
  $scope.progressBarCur = 0
  $scope.uploadedFiles = []
  $scope.dealFiles = []

  $scope.getDealFiles = () ->
    $http.get('/api/deals/'+ $routeParams.id + '/deal_assets')
    .then (respond) ->
      console.log('get files', respond)
      $scope.dealFiles = respond.data

  $scope.getIconName = (typeName) ->
    typeName && typeName.split(' ').join('-').toLowerCase()

  $scope.uploadFile =
    name: null
    size: null
    status: 'LOADING' # ERROR, SUCCESS, ABORT

  $scope.callUpload = (event) ->
    $timeout ->
      document.getElementById 'file-uploader'
        .click();
      do event.preventDefault
    , 0

  $scope.changeFile = (element) ->
    $scope.$apply ($scope) ->
      $scope.upload element.files[0]

  $scope.deleteFile = (file) ->
    if (file && file.id)
      $http.delete('/api/deals/'+ $routeParams.id + '/deal_assets/' + file.id)
      .then (respond) ->
        console.log('del file', respond)
        $scope.dealFiles = $scope.dealFiles.filter (dealFile) ->
          return dealFile.id != file.id

  $scope.retry = () ->
    $scope.upload($scope.fileToUploadTst)

  $scope.upload = (file) ->
    if not file or 'name' not of file
      return

    $scope.fileToUploadTst = file
    # console.log 'file', file
    $scope.progressBarCur = 0
    $scope.uploadFile.status = 'LOADING'
    $scope.uploadFile.name = file.name
    $scope.uploadFile.size = file.size

    $scope.uploading = Transloadit.upload(file, {
      params: {
        auth: {
          key: 'a49408107c0e11e68f21fda8b5e9bb0a'
        },

        template_id: '689738007e6b11e693c6c33c0cd97f1d'
      },

      signature: (callback) ->
#       ideally you would be generating this on the fly somewhere
        callback 'here-is-my-signature'
      ,

      progress: (loaded, total) ->
        $scope.uploadFile.size = total
        $scope.progressBarCur = loaded
        $scope.$$phase || do $scope.$apply;
      ,

      processing: () ->
        console.info 'done uploading, started processing'
      ,

      uploaded: (assemblyJson) ->
        if (assemblyJson && assemblyJson.results && assemblyJson.results[':original'] && assemblyJson.results[':original'].length)
          # console.log assemblyJson.results[':original'][0]
          folder = assemblyJson.results[':original'][0].id.slice(0, 2) + '/' + assemblyJson.results[':original'][0].id.slice(2) + '/'
          fullFileName = folder + assemblyJson.results[':original'][0].name
        $http.post('/api/deals/'+ $routeParams.id + '/deal_assets',
          {
            asset:
              asset_file_name: fullFileName
              asset_file_size: assemblyJson.results[':original'][0].size
              asset_content_type: assemblyJson.results[':original'][0].mime
              original_file_name: assemblyJson.results[':original'][0].name
          })
          .then (response) ->
            console.log(response.data)
#            $scope.uploadedFiles.push response.data
            $scope.dealFiles.push response.data

        $scope.uploadFile.status = 'SUCCESS'
        # console.log "$scope.uploadFile.status", $scope.uploadFile.status
        # console.log('uploaded', assemblyJson)
        $timeout (->
          $scope.progressBarCur = 0
          return
        ), 2000
        $scope.$$phase || $scope.$apply()
      ,

      cancel: () ->
        console.info 'upload canceled by user'
        $scope.uploadFile.status = 'ABORT'

      error: (error) ->
        $scope.uploadFile.status = 'ERROR'
        console.log('error', error)
        $scope.$$phase || $scope.$apply()

    })
    console.log '$scope.uploading', $scope.uploading
  ###*
   * END FileUpload
  ###

  $scope.init = ->
    $scope.actRemColl = false;
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    Deal.get($routeParams.id).then (deal) ->
      $scope.setCurrentDeal(deal)
      $scope.activities = deal.activities.map (activity) ->
        activity.activity_type_name = activity.activity_type && activity.activity_type.name
        activity
    , (err) ->
      if(err && err.status == 404)
        $location.url('/deals')

    $scope.anchors = [{name: 'campaign', id: 'campaign'},
                      {name: 'activities', id: 'activities'},
                      {name: 'team & split', id: 'teamsplit'},
                      {name: 'attachments', id: 'attachments'},
                      {name: 'additional info', id: 'info'}]

    $scope.getDealFiles()
    $scope.initActivity()

  $scope.initReminder = ->
    $scope.showReminder = false;

    $scope.reminder = {
      name: '',
      comment: '',
      completed: false,
      remind_on: '',
      remindable_id: $routeParams.id,
      remindable_type: 'Deal' # "Activity", "Client", "Contact", "Deal"
      _date: new Date(),
      _time: new Date()
    }

    $scope.reminderOptions = {
      editMode: false,
      errors: {},
      buttonDisabled: false,
      showMeridian: true
    }



#    Reminder.get($scope.reminder.remindable_id, $scope.reminder.remindable_type).then (reminder) ->
    $http.get('/api/remindable/'+ $scope.reminder.remindable_id + '/' + $scope.reminder.remindable_type)
    .then (respond) ->
      if (respond && respond.data && respond.data.length)
        _.each respond.data, (reminder) ->
          if (reminder && reminder.id && reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
            $scope.reminder.id = reminder.id
            $scope.reminder.name = reminder.name
            $scope.reminder.comment = reminder.comment
            $scope.reminder.completed = reminder.completed
            $scope.reminder._date = new Date(reminder.remind_on)
            $scope.reminder._time = new Date(reminder.remind_on)
            $scope.reminderOptions.editMode = true

  $scope.initReminder()

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

    $scope.activityReminderInit()

  $scope.setCurrentDeal = (deal) ->
    _.each deal.members, (member) ->
      Field.defaults(member, 'Client').then (fields) ->
        member.role = Field.field(member, 'Member Role')
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      deal.close_reason = Field.field(deal, 'Close Reason')
      $scope.currentDeal = deal
      $scope.selectedStageId = deal.stage_id
      $scope.verifyMembersShare()
      $scope.setBudgetPercent(deal)

  $scope.getStages = ->
    Stage.query().$promise.then (stages) ->
      $scope.stages = stages.filter (stage) ->
        stage.active

  $scope.toggleProductForm = ->
    $scope.resetDealProduct()
    for month in $scope.currentDeal.months
      $scope.deal_product.deal_product_budgets.push({ budget: '' })
    $scope.showProductForm = !$scope.showProductForm
    Product.all().then (products) ->
      $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

#==================add product form======================
  addProductBudgetCorrection = ->
    budgetSum = 0
    budgetPercentSum = 0
    length = $scope.deal_product.deal_product_budgets.length
    _.each $scope.deal_product.deal_product_budgets, (month, index) ->
      if(length-1 != index)
        budgetSum = budgetSum + month.budget
        budgetPercentSum = budgetPercentSum + month.percent_value
      else
        month.budget = $scope.deal_product.budget - budgetSum
        month.percent_value = 100 - budgetPercentSum

  cutSymbolsAddProductBudget = ->
    _.each $scope.deal_product.deal_product_budgets, (month) ->
        month.budget = Number((month.budget+'').replace('$', ''))
        month.percent_value = Number((month.percent_value+'').replace('%', ''))

  $scope.cutDollar = (value, index) ->
    value = Number((value+'').replace('$', ''))
    if(index != undefined )
      $scope.deal_product.deal_product_budgets[index].budget = value
    else
      return value

  $scope.setDollar = (value, index) ->
    value = '$' + value
    if(index!= undefined )
      $scope.deal_product.deal_product_budgets[index].budget = value
    else
      return value

  $scope.cutPercent = (percent_value, index) ->
    percent_value = Number((percent_value+'').replace('%', ''))
    if(index!= undefined )
      $scope.deal_product.deal_product_budgets[index].percent_value = percent_value
    else
      return percent_value

  $scope.setPercent = (percent_value, index) ->
    percent_value = percent_value + '%'
    if(index!= undefined)
      $scope.deal_product.deal_product_budgets[index].percent_value = percent_value
    else
      return percent_value

  setSymbolsAddProductBudget = ->
    _.each $scope.deal_product.deal_product_budgets, (month) ->
      month.budget = '$' + month.budget
      month.percent_value =  month.percent_value + '%'


  $scope.changeTotalBudget = ->
    $scope.deal_product.budget_percent = 100
    $scope.deal_product.isIncorrectTotalBudgetPercent = false
    budgetOneDay = $scope.deal_product.budget / $scope.currentDeal.days
    budgetSum = 0
    budgetPercentSum = 0
    _.each $scope.deal_product.deal_product_budgets, (month, index) ->
      if(!$scope.deal_product.budget)
        month.percent_value = 0
        month.budget = 0
      else
        month.budget = Math.round($scope.currentDeal.days_per_month[index] * budgetOneDay)
        month.percent_value = Math.round(month.budget / $scope.deal_product.budget * 100)
      budgetSum = budgetSum + $scope.currentDeal.days_per_month[index] * budgetOneDay
      budgetPercentSum = budgetPercentSum + month.percent_value
    if($scope.deal_product.budget && budgetSum != $scope.deal_product.budget  || budgetPercentSum && budgetPercentSum != 100)
      addProductBudgetCorrection()
    setSymbolsAddProductBudget()

  $scope.changeMonthValue = (monthValue, index)->
    if(!monthValue)
      monthValue = 0
    if((monthValue+'').length > 1 && (monthValue+'').charAt(0) == '0')
      monthValue = Number((monthValue + '').slice(1))
    $scope.deal_product.deal_product_budgets[index].budget = monthValue

    $scope.deal_product.budget = 0
    _.each $scope.deal_product.deal_product_budgets, (month, monthIndex) ->
      if(index == monthIndex)
        $scope.deal_product.budget = $scope.deal_product.budget + Number(monthValue)
      else
        $scope.deal_product.budget = $scope.deal_product.budget + $scope.cutDollar(month.budget)
    _.each $scope.deal_product.deal_product_budgets, (month) ->
      month.percent_value = $scope.setPercent( Math.round($scope.cutDollar(month.budget) / $scope.deal_product.budget * 100))

  $scope.changeMonthPercent = (monthPercentValue, index)->
    if(!monthPercentValue)
      monthPercentValue = 0
    if((monthPercentValue+'').length > 1 && (monthPercentValue+'').charAt(0) == '0')
      monthPercentValue = Number((monthPercentValue + '').slice(1))
    $scope.deal_product.deal_product_budgets[index].percent_value = monthPercentValue
    $scope.deal_product.deal_product_budgets[index].budget = $scope.setDollar(Math.round(monthPercentValue/100*$scope.deal_product.budget))

    $scope.deal_product.budget_percent = 0
    _.each $scope.deal_product.deal_product_budgets, (month) ->
      $scope.deal_product.budget_percent = $scope.cutPercent($scope.deal_product.budget_percent) + $scope.cutPercent((month.percent_value))
    if($scope.deal_product.budget_percent != 100)
      $scope.deal_product.isIncorrectTotalBudgetPercent = true
    else
      $scope.deal_product.isIncorrectTotalBudgetPercent = false

  $scope.resetAddProduct = ->
    $scope.changeTotalBudget()

  $scope.addProduct = ->
    cutSymbolsAddProductBudget()
    DealProduct.create(deal_id: $scope.currentDeal.id, deal_product: $scope.deal_product).then (deal) ->
      $scope.showProductForm = false
      $scope.currentDeal = deal
      $scope.selectedStageId = deal.stage_id
      $scope.setBudgetPercent(deal)

  $scope.resetDealProduct = ->
    $scope.deal_product = {
      deal_product_budgets: []
    }
#==================END add product form========================

#============percent and money inputs logic=====================
  $scope.saveCleanProductCopy = (deal_product)->
    $scope.copyProduct = angular.copy(deal_product)
    #    reset edit mode
    $scope.copyProduct.isIncorrectTotalBudgetPercent = false
    _.each $scope.copyProduct.deal_product_budget, (item) ->
      item.editMode = undefined

  $scope.initProductEditMode = (deal_product, deal_product_budget, elementOnFocus, isSaveCopyProduct )->
    if(isSaveCopyProduct)
      $scope.saveCleanProductCopy(deal_product)
    deal_product_budget.editMode = true
    setTimeout ->
      if(elementOnFocus == 'moneyOnFocus')
        el = angular.element('#deal_product_budget-'+ deal_product_budget.id)
      if(elementOnFocus == 'percentOnFocus')
        el = angular.element('#deal_product_budget-percent-'+ deal_product_budget.id)
      if(el)
        el.focus()

  $scope.disableProductsEditMode = (deal_product, deal_product_budgets, deal_product_budget)->
    setTimeout ->
      activeElement = document.activeElement
      if(activeElement && activeElement.id && ~activeElement.id.indexOf('deal_product_budget'))
        return
      _.each deal_product_budgets, (item) ->
        item.editMode = undefined
      if(deal_product.total_budget_percent == 100)
        $scope.updateDealProduct(deal_product)
      else
        _.each $scope.currentDeal.deal_products, (item, index) ->
          if(item.id == $scope.copyProduct.id)
            $scope.currentDeal.deal_products[index] = angular.copy($scope.copyProduct)

  $scope.changeMonthBudget = (deal_product, deal_product_budget, $index, $event, identityString) ->
    if($event && $event.which == 13)
      deal_product_budget.editMode = undefined
      $scope.disableProductsEditMode(deal_product, deal_product.deal_product_budgets, deal_product_budget)
      return
    if(identityString == "moneyOnFocus")
      if(!deal_product_budget.budget)
        deal_product_budget.budget = 0
      if((deal_product_budget.budget+'').length > 1 && (deal_product_budget.budget+'').charAt(0) == '0')
        deal_product_budget.budget = Number((deal_product_budget.budget + '').slice(1))
      deal_product.budget = 0
      _.each deal_product.deal_product_budgets, (deal_product_budget) ->
        deal_product.budget = deal_product.budget + Number(deal_product_budget.budget)
      budgetPercentSum = 0
      _.each deal_product.deal_product_budgets, (deal_product_budget) ->
        deal_product_budget.budget_percent = Math.round(deal_product_budget.budget/deal_product.budget*100)
        budgetPercentSum = budgetPercentSum + deal_product_budget.budget_percent
#      reset total_budget_percent
      deal_product.total_budget_percent = 100
      deal_product.isIncorrectTotalBudgetPercent = false;

      if(budgetPercentSum != 100)
        $scope.budgetCorrection(deal_product.deal_product_budgets, deal_product.budget)

    if(identityString == "percentOnFocus")
      deal_product_budget.budget = Math.round(deal_product_budget.budget_percent/100*deal_product.budget)
      if(!deal_product_budget.budget)
        deal_product_budget.budget = 0
      if(!deal_product_budget.budget_percent)
        deal_product_budget.budget_percent = 0
      if((deal_product_budget.budget_percent+'').length > 1 &&(deal_product_budget.budget_percent+'').charAt(0) == '0')
        deal_product_budget.budget_percent = Number((deal_product_budget.budget_percent+'').slice(1))
      budgetPercentSum = 0
      _.each deal_product.deal_product_budgets, (item) ->
        budgetPercentSum = budgetPercentSum + Number(item.budget_percent)
      deal_product.total_budget_percent = budgetPercentSum;
      if(budgetPercentSum != 100)
        deal_product.isIncorrectTotalBudgetPercent = true;
        _.each deal_product.deal_product_budgets, (item) ->
          item.editMode = true
      else
        deal_product.isIncorrectTotalBudgetPercent = false;
        _.each deal_product.deal_product_budgets, (item) ->
          if(deal_product_budget.id != item.id)
            item.editMode = undefined
      if(!deal_product_budget.budget_percent)
        deal_product_budget.budget_percent = 0

  $scope.setBudgetPercent = (deal) ->
    if(deal && deal.deal_products instanceof Array)
      _.each deal.deal_products, (deal_product) ->
        if(deal_product && deal_product.deal_product_budgets instanceof Array)
          budgetSum = 0
          budgetPercentSum = 0
          _.each deal_product.deal_product_budgets, (deal_product_budget, index) ->
            deal_product_budget.budget_percent = Math.round(deal_product_budget.budget/deal_product.budget*100)
            budgetSum = budgetSum + deal_product_budget.budget
            budgetPercentSum = budgetPercentSum + deal_product_budget.budget_percent

#            need correct data from server
#          if(budgetSum != product.total_budget || budgetPercentSum != 100)
#            $scope.budgetCorrection(product.deal_products, product.total_budget)

          deal_product.total_budget_percent = 100

  $scope.budgetCorrection = (deal_product_budgets, total_product_budget, $index) ->
    length = deal_product_budgets.length
    budgetSum = 0
    budgetPercentSum = 0
    if($index)
      _.each deal_product_budgets, (deal_product_budget, index) ->
        if(0 == index)
          budgetSum = budgetSum + Number(deal_product_budget.budget)
          budgetPercentSum = budgetPercentSum + Number(deal_product_budget.budget_percent)
      deal_product_budgets[0].budget = total_product_budget - budgetSum
      deal_product_budgets[0].budget_percent = 100 - budgetPercentSum
    else
      _.each deal_product_budgets, (deal_product_budget, index) ->
        if(length-1 != index)
          budgetSum = budgetSum + Number(deal_product_budget.budget)
          budgetPercentSum = budgetPercentSum + Number(deal_product_budget.budget_percent)
      deal_product_budgets[length-1].budget = total_product_budget - budgetSum
      deal_product_budgets[length-1].budget_percent = 100 - budgetPercentSum

#============END percent and money inputs logic=====================

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

  $scope.updateDealStage = (currentDeal, stageId) ->
    if currentDeal && stageId
      $scope.prevStageId = currentDeal.stage_id
      currentDeal.stage_id = stageId
      Stage.get(id: stageId).$promise.then (stage) ->
        if !stage.open && stage.probability == 0
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

  $scope.updateDealMember = (data) ->
    DealMember.update(id: data.id, deal_id: $scope.currentDeal.id, deal_member: data).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.onEditableBlur = () ->
    console.log("ddd")
  $scope.verifyMembersShare = ->
    share_sum = 0
    _.each $scope.currentDeal.members, (member) ->
      share_sum += member.share
    $scope.membersShareInvalid = share_sum isnt 100

  $scope.deleteMember = (member) ->
    if confirm('Are you sure you want to delete "' +  member.name + '"?')
      DealMember.delete(id: member.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal)

  $scope.deleteContact = (deletedContact) ->
    if confirm('Are you sure you want to delete "' +  deletedContact.name + '"?')
      DealContact.delete({
        deal_id: $scope.currentDeal.id,
        id: deletedContact.id
        }, ->
        $scope.currentDeal.contacts = _.reject $scope.currentDeal.contacts, (contact) ->
          contact.id == deletedContact.id
      )

  $scope.deleteDealProduct = (deal_product) ->
    if confirm('Are you sure you want to delete "' +  deal_product.name + '"?')
      DealProduct.delete(id: deal_product.id, deal_id: $scope.currentDeal.id).then (deal) ->
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
      size: 'md'
      controller: 'DealsCloseController'
      backdrop: 'static'
      keyboard: false
      resolve:
        currentDeal: ->
          currentDeal

  $scope.addContact = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_add_form.html'
      size: 'md'
      controller: 'ContactsAddController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          $scope.currentDeal

  $scope.backToPrevStage = ->
    if $scope.prevStageId
      $scope.currentDeal.stage_id = $scope.prevStageId
      $scope.selectedStageId = $scope.prevStageId

  $scope.$on 'closeDealCanceled', $scope.backToPrevStage

  $scope.$on 'openContactModal', ->
    $scope.createNewContactModal()

  $scope.$on 'updated_deal', ->
    console.log('updated_deal')
    $scope.init()

  $scope.$on 'updated_activities', ->
    console.log('updated_activities')
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
        contact: ->
          {}

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
          type: 'deal'
          data: $scope.currentDeal

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
          type: 'deal'
          data: $scope.currentDeal

  $scope.searchContact = (searchText) ->
    if ($scope.contactSearchText != searchText)
      $scope.contactSearchText = searchText
      if $scope.contactSearchText
        Contact.all1(contact_name: $scope.contactSearchText, per: 10, page: 1).then (contacts) ->
          $scope.contacts = contacts
      else
        Contact.all1(per: 10, page: 1).then (contacts) ->
          $scope.contacts = contacts
    return searchText

  $scope.getContacts = () ->
    if $scope.contacts.length == 0
      Contact.all1(per: 10, page: 1).then (contacts) ->
        $scope.contacts = contacts

  $scope.cancelActivity = ->
    $scope.initActivity()

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.contacts.push contact
      $scope.selected[$scope.activeType.name].contacts.push(contact.id)
      $scope.populateContact = false

  $scope.deleteActivity = (activity) ->
    if confirm('Are you sure you want to delete the activity?')
      Activity.delete activity, ->
        $scope.$emit('updated_activities')
  $scope.getType = (type) ->
    _.findWhere($scope.types, name: type)

  $scope.submitReminderForm = () ->
    $scope.reminderOptions.errors = {}
    $scope.reminderOptions.buttonDisabled = true
    if !($scope.reminder && $scope.reminder.name)
      $scope.reminderOptions.buttonDisabled = false
      $scope.reminderOptions.errors['Name'] = "can't be blank."
    if !($scope.reminder && $scope.reminder._date)
      $scope.reminderOptions.buttonDisabled = false
      $scope.reminderOptions.errors['Date'] = "can't be blank."
    if !($scope.reminder && $scope.reminder._time)
      $scope.reminderOptions.buttonDisabled = false
      $scope.reminderOptions.errors['Time'] = "can't be blank."
    if !$scope.reminderOptions.buttonDisabled
      return

    reminder_date = new Date($scope.reminder._date)
    if $scope.reminder._time != undefined
      reminder_time = new Date($scope.reminder._time)
      reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
    $scope.reminder.remind_on = reminder_date
    if ($scope.reminderOptions.editMode)
      Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder)
      .then (reminder) ->
        $scope.reminderOptions.buttonDisabled = false
        $scope.showReminder = false;
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false
    else
      Reminder.create(reminder: $scope.reminder).then (reminder) ->
        $scope.reminderOptions.buttonDisabled = false
        $scope.showReminder = false;
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
        $scope.reminderOptions.editMode = true
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false

  $scope.getHtml = (html) ->
    return $sce.trustAsHtml(html)
]
