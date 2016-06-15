@directives.directive 'objectList', ->
  controller: ['$scope', ($scope) ->
    $scope.loadMore = ->
      $scope.onLoadMore()
    $scope.search = (query) ->
      $scope.onSearch(query)
    $scope.select = (item) ->
      $scope.selected = item
      $scope.onSelect(item)
  ]
  scope:
    items: '='
    onLoadMore: '='
    onSearch: '='
    onSelect: '='
    query: '='
    selected: '='
    template: '@'
  templateUrl: 'partials/object_list.html'
