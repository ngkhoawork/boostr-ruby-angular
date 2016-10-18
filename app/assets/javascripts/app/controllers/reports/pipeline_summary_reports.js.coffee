@app.controller 'PipelineSummaryReportsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Deal',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Deal) ->
      $scope.sortType     = 'name'
      $scope.sortReverse  = false
      $scope.filterOpen = true
      $scope.init = ->
       currentYear = new Date().getUTCFullYear()
       $q.all({ dealData: Deal.pipeline_summary_report({filter: 'company'}) }).then (data) ->
         $scope.data = {
           'Summary': {
             '50% Prospects': null,
             '75% Prospects': null,
             '90% Prospects': null,
             'Booked': null,
             'Total': null
           },
           'Booked': null,
           '50% Prospects': null,
           '75% Prospects': null,
           '90% Prospects': null
         }

         _.each data.dealData[0].deals, (deal) ->
           if deal.stage.probability < 50
             return
           if (deal.stage.probability == 100)
             percent_key = "Booked"
           else
             percent_key = deal.stage.probability + "% Prospects"
           if (!$scope.data['Summary']['Total'])
             $scope.data['Summary']['Total'] = {}
             for i in [1 .. 12]
               $scope.data['Summary']['Total'][i] = 0
             for i in [1 .. 4]
               $scope.data['Summary']['Total']['Q' + i] = 0
             $scope.data['Summary']['Total']['FY'] = 0
           if (!$scope.data['Summary'][percent_key])
             $scope.data['Summary'][percent_key] = {}
             for i in [1 .. 12]
               $scope.data['Summary'][percent_key][i] = 0
             for i in [1 .. 4]
               $scope.data['Summary'][percent_key]['Q' + i] = 0
             $scope.data['Summary'][percent_key]['FY'] = 0
           if (!$scope.data[percent_key])
             $scope.data[percent_key] = {}

           _.each deal.deal_product_budgets, (deal_product_budget) ->
             startDate = new Date(deal_product_budget.start_date)
             month = startDate.getUTCMonth()
             year = startDate.getUTCFullYear()
             if (year != currentYear)
               return
             $scope.data['Summary'][percent_key]['FY'] += deal_product_budget.budget
             $scope.data['Summary'][percent_key][month + 1] += deal_product_budget.budget
             $scope.data['Summary'][percent_key]['Q' + (Math.ceil((month + 1) / 3))] += deal_product_budget.budget
             $scope.data['Summary']['Total']['FY'] += deal_product_budget.budget
             $scope.data['Summary']['Total'][month + 1] += deal_product_budget.budget
             $scope.data['Summary']['Total']['Q' + (Math.ceil((month + 1) / 3))] += deal_product_budget.budget
             _.each deal.users, (user) ->
               user_key = user.first_name + ' ' + user.last_name
               if (!$scope.data[percent_key][user_key])
                 $scope.data[percent_key][user_key] = {}
                 for i in [1 .. 12]
                   $scope.data[percent_key][user_key][i] = 0
                 for i in [1 .. 4]
                   $scope.data[percent_key][user_key]['Q' + i] = 0
                 $scope.data[percent_key][user_key]['FY'] = 0
               if (!$scope.data[percent_key]['Total'])
                 $scope.data[percent_key]['Total'] = {}
                 for i in [1 .. 12]
                   $scope.data[percent_key]['Total'][i] = 0
                 for i in [1 .. 4]
                   $scope.data[percent_key]['Total']['Q' + i] = 0
                 $scope.data[percent_key]['Total']['FY'] = 0
               user_product_budget = deal_product_budget.budget * user.share / 100
               $scope.data[percent_key][user_key]['FY'] += user_product_budget
               $scope.data[percent_key][user_key][month + 1] += user_product_budget
               $scope.data[percent_key][user_key]['Q' + (Math.ceil((month + 1) / 3))] += user_product_budget
               $scope.data[percent_key]['Total']['FY'] += user_product_budget
               $scope.data[percent_key]['Total'][month + 1] += user_product_budget
               $scope.data[percent_key]['Total']['Q' + (Math.ceil((month + 1) / 3))] += user_product_budget

         $scope.deals = _.map $scope.deals, (deal) ->
           products = []
           _.each $scope.productRange, (range) ->
             products.push($scope.findDealProductBudgetBudget(deal.deal_product_budgets, range) / 100)
           deal.products = products
           return deal

      $scope.init()

      $scope.findDealProductBudgetBudget = (dealProductBudgets, productTime) ->
        result =  _.find dealProductBudgets, (dealProductBudget) ->
          if (dealProductBudget.start_date == productTime)
            return dealProductBudget
        if result
          return result.budget
        else
          return 0

      $scope.changeFilter = (filterType) ->
        $scope.filterOpen = filterType

      $scope.isOpen = (deal) ->
        return deal.stage.open == $scope.filterOpen

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false
        console.log($scope.sortType)

      $scope.getHtml = (html) ->
        return $sce.trustAsHtml(html)

      $scope.exportReports = ->
        $window.open('/api/deals/pipeline_summary_report.csv')
        return true

  ]
