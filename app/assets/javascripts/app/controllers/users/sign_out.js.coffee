@app.controller 'signOutController', [
  '$scope',
  ($scope) ->
    el = angular.element('.navbar-right [data-method="delete"]')
    if(el)
      el.trigger('click')
]
