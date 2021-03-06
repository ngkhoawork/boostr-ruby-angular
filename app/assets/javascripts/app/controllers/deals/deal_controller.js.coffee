@app.controller 'DealController',
['$scope', '$routeParams', '$modal', '$filter', '$timeout', '$window', '$interval', '$location', '$anchorScroll', '$sce', 'Deal', 'Product', 'DealProduct', 'DealMember', 'DealContact', 'Stage', 'User', 'Field', 'Contact', 'Reminder', '$http', 'Transloadit', 'DealCustomFieldName', 'DealProductCfName', 'Currency', 'CurrentUser', 'ApiConfiguration', 'SSP', 'DisplayLineItem', 'Validation', 'PMPType',  'localStorageService', 'Company', 'Egnyte', 'Agreement'
( $scope,   $routeParams,   $modal,   $filter,   $timeout,   $window,   $interval,   $location,   $anchorScroll,   $sce,   Deal,   Product,   DealProduct,   DealMember,   DealContact,   Stage,   User,   Field,  Contact,    Reminder,   $http,   Transloadit,   DealCustomFieldName,   DealProductCfName,   Currency,   CurrentUser,   ApiConfiguration,   SSP,   DisplayLineItem,   Validation,   PMPType,    localStorageService,   Company,   Egnyte, Agreement) ->

  $scope.agencyRequired = false
  $scope.showMeridian = true
  $scope.isAdmin = false
  $scope.feedName = 'Deal Updates'
  $scope.types = []
  $scope.contacts = []
  $scope.errors = {}
  $scope.currencies = []
  $scope.dealMembers = []
  $scope.contactSearchText = ""
  $scope.prevStageId = null
  $scope.selectedStageId = null
  $scope.currency_symbol = '$'
  $scope.ealertReminder = false
  $scope.activitiesOrder = '-happened_at'
  $scope.isPmpDeal = false
  $scope.pmpColumns = 0
  $anchorScroll()
  $scope.operativeIntegration =
    isEnabled: false
    isLoading: false
    dealLog: null
  $scope.googleSheetsIntegration =
    isEnabled: false
  $scope.PMPType = PMPType

  ###*
   * FileUpload
  ###

  $scope.fileToUploadTst = null
  $scope.progressBarCur = 0
  $scope.dealCustomFieldNames = []
  $scope.dealProductCfNames = []
  $scope.activeDealProductCfLength = 0
  $scope.egnyteConnected = false
  $scope.egnyteHealthy = true
  $scope.egnyteIsLoading = true
  $scope.company = {}
  $scope._scope = -> this
  $scope.showWarnings = true
  roleIdWarningDisplayToShow = 1 # Role type = seller

  $scope.checkAgencyRequiredError = (errors) ->
    if errors.agency && errors.agency.length != 0
      $scope.agencyRequired = true
      $window.scrollTo 0, 0
    else
      $scope.agencyRequired = false

  CurrentUser.get().$promise.then (user) ->
    $scope.currentUser = user
    $scope.egnyte_authenticated = $scope.currentUser.egnyte_authenticated

  $scope.isUrlValid = (url) ->
    regexp = /^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?/
    regexp.test url

  $scope.getUrlHostname = (url) ->
    a = document.createElement 'a'
    a.href = $scope.fixUrl url
    a.hostname

  $scope.fixUrl = (url) ->
    if url && url.search('//') == -1 then return '//' + url else url

  $scope.getCurrentCompany = (deal) ->
    if($scope.currentUser.egnyte_authenticated)
      $scope.egnyteConnected = true

      if($routeParams.isNew)
        sendRequest(deal)
      else
        Egnyte.navigateToDeal(deal_id: deal.id).then (response) ->
          console.log(response)
          if !response.navigate_to_deal_uri
            $scope.egnyteHealthy = false
          else
            $scope.embeddedUrl = $sce.trustAsResourceUrl(response.navigate_to_deal_uri)
            $scope.egnyteIsLoading = false
            $scope.egnyteHealthy = true

  sendRequest = (deal) ->
    $scope.egnyteUrlRequest = $timeout (->
      Egnyte.navigateToDeal(deal_id: deal.id).then (response) ->
        if response.navigate_to_deal_uri
          $scope.embeddedUrl = $sce.trustAsResourceUrl(response.navigate_to_deal_uri)
          $scope.egnyteIsLoading = false
          $scope.egnyteHealthy = true
          $location.search({})

        else
          sendRequest(deal)
      return
    ), 3000

  $scope.$on '$destroy', ->
    if $scope.egnyteUrlRequest
      $timeout.cancel($scope.egnyteUrlRequest);

  $scope.init = (initialLoad) ->
    $scope.actRemColl = false
    $scope.currentDeal = {}
    $scope.resetDealProduct()
    Deal.get($routeParams.id).then (deal) ->
      $scope.setCurrentDeal(deal, true)
      $scope.getCurrentCompany(deal)

      if initialLoad
        checkCurrentUserDealShare(deal.members)
        getOperativeIntegration(deal.id)
        getGoogleSheetsIntegration(deal.id)
        getAgreements()
    , (err) ->
      if(err && err.status == 404)
        $location.url('/deals')

        $scope.anchors = [{name: 'campaign', id: 'campaign'},
                      {name: 'activities', id: 'activities'},
                      {name: 'team & split', id: 'teamsplit'},
                      {name: 'attachments', id: 'attachments'},
                      {name: 'additional info', id: 'info'}]

    getDealCustomFieldNames()
    getDealProductCfNames()
    getValidations()
    Company.get().$promise.then (company) -> $scope.company = company
    getSsps()

  getAgreements = ->
    Agreement.get_deal_agreements({ deal_id: $scope.currentDeal.id })
      .$promise.then (agreements) -> 
        agreements.forEach (agreement) ->
          if agreement.spend_agreement
            agreement.spend_agreement.allAdvertisers = agreement.spend_agreement.parent_companies.concat(agreement.spend_agreement.advertisers)
        $scope.currentDeal.agreements = agreements if agreements

  $scope.excludeAgreement = (agreement) ->
    if confirm('Are you sure you want to exclude "' +  agreement.spend_agreement.name + '"?')
        Agreement.exclude_deal( { spend_agreement_id: agreement.spend_agreement.id, id: agreement.id }
            (data) -> getAgreements()
            (reject) -> console.error reject
        )    

  checkPmpDeal = () ->
    $scope.isPmpDeal = false
    $scope.pmpColumns = 0
    _.each $scope.currentDeal.products, (product) ->
      if product.revenue_type == 'PMP'
        $scope.isPmpDeal = true
        $scope.pmpColumns = 3

  getSsps = () ->
    SSP.all().then (ssps) ->
      $scope.ssps = ssps

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

  getDealProductCfNames = () ->
    DealProductCfName.all().then (dealProductCfNames) ->
      $scope.dealProductCfNames = dealProductCfNames
      $scope.activeDealProductCfLength = (_.filter dealProductCfNames, (item) -> !item.disabled).length

  getValidations = () ->
    Validation.deal_base_fields().$promise.then (data) ->
      $scope.base_fields_validations = data
    Validation.query(factor: 'Require Won Reason').$promise.then (data) ->
      $scope.won_reason_required = data && data[0]

  $scope.sumDealProductBudget = (index) ->
    products = $scope.currentDeal.deal_products
    _.reduce products, (result, product) ->
      if !_.isUndefined index then product = product.deal_product_budgets[index]
      result += parseInt product.budget_loc
    , 0

  $scope.initReminder = ->

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
      showReminder: false
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

  $scope.getCompanyCurrencies = ->
    Currency.active_currencies().then (currencies) ->
      $scope.currencies = currencies
  $scope.getCompanyCurrencies()

  $scope.updateDealCurrency = (currentDeal, curr_cd)->
    $scope.errors = {}
    currentDeal.curr_cd = curr_cd
    Deal.update(id: currentDeal.id, deal: currentDeal).then(
      (deal) ->
        $scope.ealertReminder = true
      (resp) ->
        if resp.data.errors
          $scope.checkAgencyRequiredError resp.data.errors

        $timeout ->
          delete $scope.errors.curr_cd
        , 6000
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
    )

  setValidDeal = () ->
    $scope.currentDeal.validDeal = true
    _.each $scope.dealCustomFieldNames, (dealCustomFieldName) ->
      fieldName = dealCustomFieldName.field_type + dealCustomFieldName.field_index
      if dealCustomFieldName.is_required == true && (!$scope.currentDeal.deal_custom_field || !$scope.currentDeal.deal_custom_field[fieldName])
        $scope.currentDeal.validDeal = false
    _.each $scope.dealProductCfNames, (dealProdctCfName) ->
      productFieldName = dealProdctCfName.field_type + dealProdctCfName.field_index
      if dealProdctCfName.is_required == true
        _.each $scope.currentDeal.deal_products, (dealProduct) ->
          if !dealProduct.deal_product_cf || !dealProduct.deal_product_cf[productFieldName]
            $scope.currentDeal.validDeal = false

  getDealStage = ->
    $scope.currentDeal.stage.won = !$scope.currentDeal.stage.open && $scope.currentDeal.stage.probability >= 100

  $scope.setCurrentDeal = (deal, shouldUsersUpdate) ->
    $scope.currency_symbol = deal.currency && (deal.currency.curr_symbol || deal.currency.curr_cd)

    if shouldUsersUpdate
      $scope.dealMembers = angular.copy deal.members
      _.each $scope.dealMembers, (member) ->
        Field.defaults(member, 'Client').then (fields) ->
          member.role = Field.field(member, 'Member Role')

    Field.defaults(deal, 'Deal').then (fields) ->
      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      deal.close_reason = Field.field(deal, 'Close Reason')
      deal.contact_roles = Field.field(deal, 'Contact Role')
      deal.next_steps_expired = moment(deal.next_steps_due) < moment().startOf('day')
    $scope.currentDeal = deal
    $scope.selectedStageId = deal.stage_id
    $scope.start_date = deal.start_date
    $scope.end_date = deal.end_date
    deal.start_date = moment(deal.start_date).toDate()
    deal.end_date = moment(deal.end_date).toDate()
    $scope.verifyMembersShare()
    $scope.setBudgetPercent(deal)
    $scope.getStages()
    checkPmpDeal()
    getAgreements()
    getDealStage()

  $scope.getStages = ->
    Stage.query({active: true, sales_process_id: $scope.currentDeal.stage.sales_process_id}).$promise.then (stages) ->
      $scope.stages = stages

  $scope.toggleProductForm = ->
    $scope.resetDealProduct()
    for month in $scope.currentDeal.months
      $scope.deal_product.deal_product_budgets.push({ budget_loc: '' })
    $scope.showProductForm = !$scope.showProductForm
    Product.all({active: true}).then (products) ->
      $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

#==================add product form======================
  addProductBudgetCorrection = ->
    budgetSum = 0
    budgetPercentSum = 0
    length = $scope.deal_product.deal_product_budgets.length
    _.each $scope.deal_product.deal_product_budgets, (month, index) ->
      if(length-1 != index)
        budgetSum = budgetSum + month.budget_loc
        budgetPercentSum = budgetPercentSum + month.percent_value
      else
        month.budget_loc = $scope.deal_product.budget_loc - budgetSum
        month.percent_value = 100 - budgetPercentSum

  cutSymbolsAddProductBudget = ->
    _.each $scope.deal_product.deal_product_budgets, (month) ->
        month.budget_loc = Number((month.budget_loc+'').replace($scope.currency_symbol, ''))
        month.percent_value = Number((month.percent_value+'').replace('%', ''))

  $scope.cutCurrencySymbol = (value, index) ->
    value = Number((value + '').replace($scope.currency_symbol, ''))
    if(index != undefined )
      $scope.deal_product.deal_product_budgets[index].budget_loc = value
    else
      return value

  $scope.setCurrencySymbol = (value, index) ->
    value = $scope.currency_symbol + value
    if(index!= undefined )
      $scope.deal_product.deal_product_budgets[index].budget_loc = value
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
      month.budget_loc = $scope.currency_symbol + month.budget_loc
      month.percent_value =  month.percent_value + '%'


  $scope.changeTotalBudget = ->
    $scope.deal_product.budget_percent = 100
    $scope.deal_product.isIncorrectTotalBudgetPercent = false
    budgetOneDay = $scope.deal_product.budget_loc / $scope.currentDeal.days
    budgetSum = 0
    budgetPercentSum = 0
    _.each $scope.deal_product.deal_product_budgets, (month, index) ->
      if(!$scope.deal_product.budget_loc)
        month.percent_value = 0
        month.budget_loc = 0
      else
        month.budget_loc = Math.round($scope.currentDeal.days_per_month[index] * budgetOneDay)
        month.percent_value = Math.round(month.budget_loc / $scope.deal_product.budget_loc * 100)
      budgetSum = budgetSum + $scope.currentDeal.days_per_month[index] * budgetOneDay
      budgetPercentSum = budgetPercentSum + month.percent_value
    if($scope.deal_product.budget_loc && budgetSum != $scope.deal_product.budget_loc  || budgetPercentSum && budgetPercentSum != 100)
      addProductBudgetCorrection()
    setSymbolsAddProductBudget()

  $scope.changeMonthValue = (monthValue, index)->
    if(!monthValue)
      monthValue = 0
    if((monthValue+'').length > 1 && (monthValue+'').charAt(0) == '0')
      monthValue = Number((monthValue + '').slice(1))
    $scope.deal_product.deal_product_budgets[index].budget_loc = monthValue

    $scope.deal_product.budget_loc = 0
    _.each $scope.deal_product.deal_product_budgets, (month, monthIndex) ->
      if(index == monthIndex)
        $scope.deal_product.budget_loc = $scope.deal_product.budget_loc + Number(monthValue)
      else
        $scope.deal_product.budget_loc = $scope.deal_product.budget_loc + $scope.cutCurrencySymbol(month.budget_loc)
    _.each $scope.deal_product.deal_product_budgets, (month) ->
      month.percent_value = $scope.setPercent( Math.round($scope.cutCurrencySymbol(month.budget_loc) / $scope.deal_product.budget_loc * 100))

  $scope.changeMonthPercent = (monthPercentValue, index)->
    if(!monthPercentValue)
      monthPercentValue = 0
    if((monthPercentValue+'').length > 1 && (monthPercentValue+'').charAt(0) == '0')
      monthPercentValue = Number((monthPercentValue + '').slice(1))
    $scope.deal_product.deal_product_budgets[index].percent_value = monthPercentValue
    $scope.deal_product.deal_product_budgets[index].budget_loc = $scope.setCurrencySymbol(Math.round(monthPercentValue/100*$scope.deal_product.budget_loc))

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
    $scope.errors = {}
    cutSymbolsAddProductBudget()
    DealProduct.create(deal_id: $scope.currentDeal.id, deal_product: $scope.deal_product).then(
      (deal) ->
        $scope.showProductForm = false
        $scope.currentDeal = deal
        $scope.selectedStageId = deal.stage_id
        $scope.setBudgetPercent(deal)
        $scope.ealertReminder = true
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
    )
  $scope.$on 'deal_product_added', (e, deal) ->
    $scope.setCurrentDeal(deal)

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
      if(!deal_product_budget.budget_loc)
        deal_product_budget.budget_loc = 0
      if((deal_product_budget.budget_loc+'').length > 1 && (deal_product_budget.budget_loc+'').charAt(0) == '0')
        deal_product_budget.budget_loc = Number((deal_product_budget.budget_loc + '').slice(1))
      deal_product.budget_loc = 0
      _.each deal_product.deal_product_budgets, (deal_product_budget) ->
        deal_product.budget_loc = deal_product.budget_loc + Number(deal_product_budget.budget_loc)
      budgetPercentSum = 0
      _.each deal_product.deal_product_budgets, (deal_product_budget) ->
        deal_product_budget.budget_percent = Math.round(deal_product_budget.budget_loc/deal_product.budget_loc*100)
        budgetPercentSum = budgetPercentSum + deal_product_budget.budget_percent
#      reset total_budget_percent
      deal_product.total_budget_percent = 100
      deal_product.isIncorrectTotalBudgetPercent = false;

      if(budgetPercentSum != 100)
        $scope.budgetCorrection(deal_product.deal_product_budgets, deal_product.budget_loc)

    if(identityString == "percentOnFocus")
      deal_product_budget.budget_loc = Math.round(deal_product_budget.budget_percent/100*deal_product.budget_loc)
      if(!deal_product_budget.budget_loc)
        deal_product_budget.budget_loc = 0
      if(!deal_product_budget.budget_percent)
        deal_product_budget.budget_percent = 0
      if((deal_product_budget.budget_percent+'').length > 1 &&(deal_product_budget.budget_percent+'').charAt(0) == '0')
        deal_product_budget.budget_percent = Number((deal_product_budget.budget_percent+'').slice(1))
      budgetPercentSum = 0
      _.each deal_product.deal_product_budgets, (item) ->
        budgetPercentSum = budgetPercentSum + Number(item.budget_percent)
      deal_product.total_budget_percent = Number(budgetPercentSum.toFixed(1))
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
            deal_product_budget.budget_percent = Number((deal_product_budget.budget_loc / deal_product.budget_loc * 100).toFixed(1))
            budgetSum = budgetSum + deal_product_budget.budget_loc
            budgetPercentSum = budgetPercentSum + deal_product_budget.budget_percent
        if(budgetSum != deal_product.budget_loc || budgetPercentSum != 100)
          $scope.budgetCorrection(deal_product.deal_product_budgets, deal_product.budget_loc)

          deal_product.total_budget_percent = 100

  $scope.budgetCorrection = (deal_product_budgets, total_product_budget, $index) ->
    length = deal_product_budgets.length
    budgetSum = 0
    budgetPercentSum = 0
    if($index)
      _.each deal_product_budgets, (deal_product_budget, index) ->
        if(0 == index)
          budgetSum = budgetSum + Number(deal_product_budget.budget_loc)
          budgetPercentSum = budgetPercentSum + Number(deal_product_budget.budget_percent)
      deal_product_budgets[0].budget_loc = total_product_budget - budgetSum.toFixed(2)
      deal_product_budgets[0].budget_percent = 100 - budgetPercentSum.toFixed(2)
    else
      _.each deal_product_budgets, (deal_product_budget, index) ->
        if(length-1 != index)
          budgetSum = budgetSum + Number(deal_product_budget.budget_loc)
          budgetPercentSum = budgetPercentSum + Number(deal_product_budget.budget_percent)
      last_budget = total_product_budget - budgetSum.toFixed(2)
      last_percentage = Number(100 - budgetPercentSum.toFixed(1)).toFixed(1)
      deal_product_budgets[length-1].budget_loc = last_budget
      if last_percentage < 0 || isNaN(last_percentage || last_budget == 0)
        deal_product_budgets[length-1].budget_percent = 0
      else
        deal_product_budgets[length-1].budget_percent = last_percentage

#============END percent and money inputs logic=====================

  $scope.showLinkExistingUser = ->
    User.query().$promise.then (users) ->
      $scope.users = $filter('notIn')(users, $scope.currentDeal.members, 'user_id')

  $scope.linkExistingUser = (item, select) ->
    $scope.userToLink = undefined
    select.selected = null
    DealMember.create(deal_id: $scope.currentDeal.id, deal_member: { user_id: item.id, share: 0, values: [] }).then (deal) ->
      $scope.setCurrentDeal(deal, true)

  $scope.updateDeal = ->
    $scope.errors = {}
    ($scope.base_fields_validations || []).forEach (validation) ->
      if $scope.currentDeal && (!$scope.currentDeal[validation.factor] && !validationValueFactorExists($scope.currentDeal, validation.factor))
        $scope.errors[validation.factor] = validation.name + ' is required'

    if $scope.errors
      $scope.checkAgencyRequiredError $scope.errors

    if Object.keys($scope.errors).length > 0 then return

    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then(
      (deal) ->
        if deal.info_messages.length
          $scope.infoModalInstance = $modal.open
            templateUrl: 'modals/info_modal.html'
            size: 'md'
            controller: 'AgreementInfoController'
            backdrop: 'static'
            keyboard: false
            resolve:
              options: ->
                  messages: deal.info_messages
                  typeOfExcluded: 'agreement'
                  typeOfUpdate: 'deal'
        $scope.ealertReminder = true
        getAgreements()
      (resp) ->
        if resp.data.errors
          $scope.checkAgencyRequiredError resp.data.errors

        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
    )

  $scope.moment = moment

  $scope.updateDealDate = (key) ->
    deal = $scope.currentDeal
    deal.start_date = moment(deal.start_date).format('YYYY-MM-DD')
    deal.end_date = moment(deal.end_date).format('YYYY-MM-DD')
    if moment(deal.start_date).isSameOrBefore(deal.end_date)
      $scope.updateDeal()
    else
      deal[key] = moment($scope[key]).format('YYYY-MM-DD')
      $scope.errors.campaignPeriod = 'End Date can\'t be before Start Date'
      $timeout (-> delete $scope.errors.campaignPeriod), 6000

  validationValueFactorExists = (deal, factor) ->
    if factor == 'deal_type_value'
      deal.deal_type && deal.deal_type.option_id
    else if factor == 'deal_source_value'
      deal.source_type && deal.source_type.option_id
    else if factor == 'agency'
      deal && deal.agency_id

  $scope.updateDealStage = (currentDeal, stageId) ->
    $scope.errors = {}
    if currentDeal && stageId
      $scope.prevStageId = currentDeal.stage_id
      currentDeal.stage_id = stageId
      Stage.get(id: stageId).$promise.then (stage) ->
        # validation check for pmp products
        if !stage.open && $scope.isPmpDeal
          for deal_product in $scope.currentDeal.deal_products
            if !deal_product.ssp_id
              $scope.errors['ssp_id' + deal_product.id] = "can't be blank"
            if !deal_product.ssp_deal_id
              $scope.errors['ssp_deal_id' + deal_product.id] = "can't be blank"
            if !deal_product.pmp_type
              $scope.errors['pmp_type' + deal_product.id] = "can't be blank"
        if !_.isEmpty($scope.errors)
          $scope.showWarningModal('SSP, SSP Deal-ID and PMP Type fields are required for PMP products.')
          return
        if !stage.open && stage.probability == 0
          $scope.showWonLossModal(currentDeal, false)
        else if !stage.open && stage.probability == 100 && $scope.won_reason_required && $scope.won_reason_required.criterion.value
          $scope.showWonLossModal(currentDeal, true)
        else
          Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then(
            (deal) ->       
              if currentDeal.close_reason.option then $scope.init()
              $scope.ealertReminder = true
            (resp) ->
              if resp.data.errors
                $scope.checkAgencyRequiredError resp.data.errors

              $timeout ->
                delete $scope.errors.stage
              , 6000
              for key, error of resp.data.errors
                $scope.errors[key] = error && error[0]
          )

  $scope.updateDealProduct = (data) ->
    $scope.errors = {}
    DealProduct.update(id: data.id, deal_id: $scope.currentDeal.id, deal_product: data).then(
      (deal) ->
        $scope.setCurrentDeal(deal)
        $scope.ealertReminder = true
      (resp) ->
        if resp.data.errors
          $scope.checkAgencyRequiredError resp.data.errors

        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
    )

  $scope.findById = (arr, id)->
    _.findWhere arr, id: id

  totalSplitShare = () ->
    _.reduce $scope.dealMembers, (sum, dealMember) ->
      sum + parseInt(dealMember.share)
    , 0

  $scope.updateDealMember = (data) ->
    if totalSplitShare() > 100
      data.share = _.find($scope.currentDeal.members, (member) -> member.id == data.id).share
      $scope.showWarningModal 'Deal split % cannot exceed 100%. Update your split % to sum to 100%.', null
    else
      DealMember.update(id: data.id, deal_id: $scope.currentDeal.id, deal_member: data).then (deal) ->
        $scope.setCurrentDeal(deal, true)
        checkCurrentUserDealShare(deal.members)

  $scope.onEditableBlur = () ->
  $scope.verifyMembersShare = ->
    share_sum = 0
    _.each $scope.currentDeal.members, (member) ->
      share_sum += member.share
    $scope.membersShareInvalid = share_sum isnt 100

  $scope.deleteMember = (member) ->
    if confirm('Are you sure you want to delete "' +  member.name + '"?')
      DealMember.delete(id: member.id, deal_id: $scope.currentDeal.id).then (deal) ->
        $scope.setCurrentDeal(deal, true)

  $scope.showContactEditModal = (deal_contact) ->
    deal_contact.errors = {}

    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'md'
      controller: 'ContactsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          deal_contact.contact

  $scope.showNewRequestModal = (requestable, requestable_type) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/request_form.html'
      size: 'md'
      controller: 'RequestsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal_id: ->
          $scope.currentDeal.id
        requestable: ->
          requestable
        requestable_type: ->
          requestable_type

  $scope.deleteContact = (deletedContact) ->
    if confirm('Are you sure you want to delete "' +  deletedContact.contact.name + '"?')
      DealContact.delete(deal_id: $scope.currentDeal.id, id: deletedContact.id).then (deal_contact) ->
        $scope.currentDeal.deal_contacts = _.reject $scope.currentDeal.deal_contacts, (deal_contact) ->
          deal_contact.id == deletedContact.id

  $scope.submitDealContact = (deal_contact, option) ->
    if option == 'Billing'
      if !confirm("Confirm you want to assign an unrelated billing contact")
        return
    deal_contact.role = option;
    deal_contact.errors = {}

    DealContact.update(
      deal_id: $scope.currentDeal.id,
      id: deal_contact.id,
      deal_contact: deal_contact
    ).then(
      (deal_contact) ->
        true
      (resp) ->
        $timeout ->
          delete deal_contact.errors.role
        , 6000
        deal_contact.role = null
        for key, error of resp.data.errors
          deal_contact.errors[key] = error && error[0]
    )

  $scope.removeDealInitiative = (e) ->
    e.stopPropagation()
    $scope.currentDeal.initiative_id = null
    $scope.updateDeal()

  $scope.deleteDealProduct = (deal_product) ->
    $scope.errors = {}
    if confirm('Are you sure you want to delete "' +  deal_product.product.full_name + '"?')
      DealProduct.delete(id: deal_product.id, deal_id: $scope.currentDeal.id).then(
        (deal) ->
          $scope.setCurrentDeal(deal)
          $scope.ealertReminder = true
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

  $scope.isActive = (id) ->
    $scope.activeAnchor == id

  $scope.scrollTo = (id) ->
    $scope.activeAnchor = id
    $anchorScroll(id)

  $scope.cancelAddProduct = ->
    $scope.showProductForm = !$scope.showProductForm

  $scope.showWonLossModal = (currentDeal, hasWon) ->
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

  $scope.showWarningModal = (message, id) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_warning.html'
      size: 'md'
      controller: 'DealWarningController'
      backdrop: 'static'
      keyboard: true
      resolve:
        message: -> message
        id: -> id

  $scope.showNewProductModal = (currentDeal) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_new_product_form.html'
      size: 'lg'
      controller: 'DealNewProductController'
      backdrop: 'static'
      keyboard: false
      resolve:
        currentDeal: ->
          currentDeal
        company: ->
          $scope.company
        isPmpDeal: ->
          $scope.isPmpDeal

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
        publisher: ->
          {}

  $scope.addAgreement = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/agreement_assign.html'
      size: 'md'
      controller: 'AgreementsAssignController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: -> $scope.currentDeal
    .result.then (agreements) -> getAgreements()

  $scope.backToPrevStage = ->
    if $scope.prevStageId
      $scope.currentDeal.stage_id = $scope.prevStageId
      $scope.selectedStageId = $scope.prevStageId

  $scope.$on 'closeDealCanceled', $scope.backToPrevStage

  $scope.$on 'updated_deals', (event, deal, action) ->
    if deal && action != 'delete' then $scope.setCurrentDeal(deal)

  $scope.$on 'updated_reminders', ->
    $scope.initReminder()

  $scope.$on 'deal_update_errors', (event, errors) ->
    $scope.errors = {}
    for key, error of errors
      $scope.errors[key] = error && error[0]

  $scope.init(true)

  $scope.setActiveTab = (tab) ->
    $scope.activeTab = tab

  $scope.setActiveType = (type) ->
    $scope.activeType = type

  $scope.showDealEditModal = (deal) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'md'
      controller: 'DealsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          angular.copy deal
    .result.then (deal) -> getAgreements() if deal

  $scope.showDealEalertModal = (deal) ->
    setValidDeal()
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/ealert_form.html'
      size: 'lg'
      controller: 'DealsEalertController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          angular.copy deal
    .result.then (response) ->
      if response
        $scope.ealertReminder = false

  $scope.deleteDeal = (deal) ->
    $scope.errors = {}
    if confirm('Are you sure you want to delete "' +  deal.name + '"?')
      Deal.delete(deal).then(
        (deal) ->
          $location.path('/deals')
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

  $scope.searchContact = (searchText) ->
    if ($scope.contactSearchText != searchText)
      $scope.contactSearchText = searchText
      if $scope.contactSearchText
        Contact.all1(q: $scope.contactSearchText, per: 10, page: 1).then (contacts) ->
          $scope.contacts = contacts
      else
        Contact.all1(per: 10, page: 1).then (contacts) ->
          $scope.contacts = contacts
    return searchText

  $scope.getContacts = () ->
    if $scope.contacts.length == 0
      Contact.all1(per: 10, page: 1).then (contacts) ->
        $scope.contacts = contacts

  $scope.$on 'newContact', (event, contact) ->
    if $scope.populateContact
      $scope.contacts.push contact
      $scope.selected[$scope.activeType.name].contacts.push(contact.id)
      $scope.populateContact = false

  $scope.baseFieldRequired = (factor) ->
    if $scope.currentDeal && $scope.base_fields_validations
      validation = _.findWhere($scope.base_fields_validations, factor: factor)
      return validation?

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
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false
    else
      Reminder.create(reminder: $scope.reminder).then (reminder) ->
        $scope.reminderOptions.buttonDisabled = false
        $scope.reminder = reminder
        $scope.reminder._date = new Date($scope.reminder.remind_on)
        $scope.reminder._time = new Date($scope.reminder.remind_on)
        $scope.reminderOptions.editMode = true
      , (err) ->
        $scope.reminderOptions.buttonDisabled = false

  $scope.getHtml = (html) ->
    return $sce.trustAsHtml(html)

  $scope.showBudgetRow = (item, e)->
    budgetsRow = angular.element("[data-displayID='#{item.id}']")
    innerDiv = budgetsRow.children()
    angular.element('.display-line-budgets').outerHeight(0)
    if $scope.selectedIORow == item
        $scope.selectedIORow = null
    else
        $scope.selectedIORow = null
        DisplayLineItem.get(item.id).then (budgets) ->
            $scope.selectedIORow = item
            $scope.budgets = budgets
            calcRestBudget()
            $timeout -> budgetsRow.height innerDiv.outerHeight()
    return

  $scope.sendToOperative = (dealId)->
    Deal.send_to_operative(id: dealId).then () ->
      currentLog = $scope.operativeIntegration.dealLog
      $scope.operativeIntegration.isLoading = true
      attempts = 30
      interval = $interval ->
        attempts--
        if attempts <= 0
          $interval.cancel(interval)
          $scope.operativeIntegration.isLoading = false
          return console.error('Updating operative deal status: the maximum number of attempts is reached')
        Deal.latest_log(id: dealId).then (log) ->

          if (currentLog && (log && log.id != currentLog.id)) || (!currentLog && log && log.id)
            $interval.cancel(interval)
            $scope.operativeIntegration.dealLog = log
            $scope.operativeIntegration.isLoading = false
      , 2000

  $scope.sendToGoogleSheet = (dealId)->
    Deal.send_to_google_sheet(id: dealId)

  calcRestBudget = () ->
    sum = _.reduce($scope.budgets, (res, budget) ->
      res += Number(budget.budget_loc) || 0
    , 0)
    $scope.budgets && $scope.budgets.rest = $scope.selectedIORow.budget_loc - sum

  getOperativeIntegration = (dealId) ->
    ApiConfiguration.all().then (data) ->
      operative = _.findWhere data.api_configurations, integration_type: 'OperativeApiConfiguration'
      if operative && operative.switched_on
        $scope.operativeIntegration.isEnabled = operative.switched_on
        Deal.latest_log(id: dealId).then (log) ->
          $scope.operativeIntegration.dealLog = log if log && log.id

  getGoogleSheetsIntegration = (dealId) ->
    ApiConfiguration.all().then (data) ->
      google_sheets = _.findWhere data.api_configurations, integration_type: 'GoogleSheetsConfiguration'
      if google_sheets && google_sheets.switched_on
        $scope.googleSheetsIntegration.isEnabled = google_sheets.switched_on

  $scope.getWarningSettings = () ->
    dealsWithoutWarning = localStorageService.get('dealsWithoutWarning') || []
    dealsWithoutWarning.forEach((deal) ->
      if deal.dealId == $scope.currentDeal.id
        $scope.showWarnings = false
    )


  checkCurrentUserDealShare = (members) ->
    CurrentUser.get().$promise.then (currentUser) ->
      $scope.getWarningSettings()
      _.forEach members, (member) ->
        if member.user_id == currentUser.id && !(member.share > 0) && $scope.showWarnings && currentUser.user_type == roleIdWarningDisplayToShow
          $scope.showWarningModal 'You have 0% split share on this Deal. Update your split % if incorrect.', $scope.currentDeal.id

  $scope.$watch 'currentUser', (currentUser) ->
    $scope.isAdmin = _.contains currentUser.roles, 'admin' if currentUser

  $scope.toggleDrodown = (event) ->
    dropdown = angular.element(event.target).next()
    tableWrapper = angular.element('#agreements-section table').parent()

    if dropdown.is(':visible')
      dropdown.hide()
      # Add overflow-x: auto if dropdown is closed
      tableWrapper.addClass('table-wrapper')
      return
    else
      multipleLists = angular.element('.multiple-list-wrapper')
      multipleLists.hide()
      dropdown.show()
      # Remove overflow-x: auto if dropdown is open
      tableWrapper.removeClass('table-wrapper')
      return

  $window.addEventListener 'click', (event) ->
    target = angular.element(event.target)
    if target.closest(".multiple").length == 0
      multipleLists = angular.element('.multiple-list-wrapper')
      multipleLists.hide()  

]
