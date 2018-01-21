app.directive 'tree', ->
  {
    restrict: 'E'
    replace: true
    scope: t: '=src'
    template: '<ul class="folders"><branch ng-repeat="c in t.nodes" src="c"></branch></ul>'
  }
app.directive 'branch', ($compile) ->
  {
    restrict: 'E'
    replace: true
    scope: b: '=src'
    templateUrl: 'directives/folder-structure.html'
    controller: ($scope, $rootScope) ->
      $scope.activeFolder = (event, folder) ->
        if $(event.target).hasClass('block')
          $rootScope.$broadcast 'handleActionButtons', folder
        else
          $rootScope.$broadcast 'handleActionButtons'

    link: (scope, element, attrs) ->
      has_subfolders = angular.isArray(scope.b.nodes)
      if has_subfolders
        element.append '<tree src="b"></tree>'
        $compile(element.contents()) scope

      element.on 'click', (event) ->
        _.each $('.block'), (item) ->
          $(item).removeClass 'active'

        $(event.target).toggleClass 'active' if $(event.target).hasClass 'block'

        return false if !$(event.target).hasClass 'click-trigger'
        event.stopPropagation()

        element.find('i').toggleClass('fa-folder').toggleClass 'fa-folder-open'
        element.find('span').toggleClass('triangle-down').toggleClass 'triangle-left'
        if has_subfolders
          element.toggleClass 'collapsed'

  }
