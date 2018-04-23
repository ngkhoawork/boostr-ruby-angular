app.directive 'tree', ->
  {
    restrict: 'E'
    replace: true
    scope: t: '=src'
    template: '<ul class="folders"><branch ng-repeat="c in t.nodes" src="c" parent="t"></branch></ul>'
  }
app.directive 'branch', ($compile) ->
  {
    restrict: 'E'
    replace: true
    scope: { b: '=src', parentFolder: '=parent' }
    templateUrl: 'directives/folder-structure.html'

    controller: ($scope, $rootScope) ->
      $scope.activeFolder = (event, folder) ->
        if $(event.target).hasClass('block') || $(event.target).hasClass('folder-actions')
          $rootScope.$broadcast 'handleActionButtons', folder, $scope.parentFolder
        else
          $rootScope.$broadcast 'handleActionButtons'

      $scope.editFolder = (event, currentFolder) ->
        $rootScope.$broadcast 'editFolder', currentFolder

      $scope.deleteFolder = (event, currentFolder) ->
        if confirm('Are you sure you want to delete "' + currentFolder.title + '"?')
          $rootScope.$broadcast 'deleteFolder', currentFolder

    link: (scope, element, attrs) ->
      has_subfolders = angular.isArray(scope.b.nodes)

      if has_subfolders
        element.append '<tree src="b"></tree>'
        $compile(element.contents()) scope

      $(".block").on 'mouseenter', (event) ->
        $(event.target).find('.folder-actions').addClass 'show'

      $(".block").on 'mouseleave', (event) ->
        $('.folder-actions').removeClass 'show'

      element.on 'click', (event) ->
        _.each $('.block'), (item) ->
          $(item).removeClass 'active'

        if $(event.target).hasClass 'folder-title'
          $(event.target).parent().toggleClass 'active'
        else if $(event.target).hasClass 'folder-actions'
          $(event.target).parent().parent().toggleClass 'active'

        return false if !$(event.target).hasClass 'click-trigger'
        event.stopPropagation()

        element.find('i.folder-icon').toggleClass('fa-folder').toggleClass 'fa-folder-open'
        element.find('span').toggleClass('triangle-down').toggleClass 'triangle-left'
        if has_subfolders
          element.toggleClass 'collapsed'

  }
