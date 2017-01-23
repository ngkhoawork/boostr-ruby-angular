@app.service 'LastWeekDealsReportService',
  ['$resource', '$q',
    ($resource, $q) ->
      resource = $resource 'api/deal_reports', {}
      resource
]