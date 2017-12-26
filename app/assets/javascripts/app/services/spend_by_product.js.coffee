@service.service 'SpendByAccount',
  ['$resource'
    ( $resource ) ->

      resource = $resource '/api/revenue/', {},
        SpendByAccountReport:
          method: 'GET'
          url: '/api/revenue/report_by_account'
          isArray: true
  

      this.SpendByAccountReport = (params) -> resource.SpendByAccountReport(params).$promise
      return
  ]