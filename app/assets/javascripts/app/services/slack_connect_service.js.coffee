@app.service 'SlackConnectService',
  ['$q', '$resource',
    ($q, $resource) ->

      resource = $resource '/api/slack/auth'

      @auth = () ->
        deferred = $q.defer()

        resource.save(
          (data) ->
            deferred.resolve(data)
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      return
  ]
