@app.controller 'PablisherController', [
  '$scope', '$modal', '$filter', '$routeParams', 'Publisher', 'PublisherDetails', 'PublisherMembers', '$rootScope', 'User', 'PublisherCustomFieldName',
  ($scope,   $modal,   $filter,   $routeParams,   Publisher,   PublisherDetails, PublisherMembers, $rootScope, User, PublisherCustomFieldName) ->

    $scope.currentPublisher = {}

    $scope.init = ->
      PublisherDetails.getPublisher(id: $routeParams.id).then (publisher) ->
        $scope.currentPublisher = publisher
        console.log(publisher)

      PublisherDetails.associations(id: $routeParams.id).then (association) ->
        $scope.contacts = association.contacts
        $scope.publisherMembers = association.members

      PublisherCustomFieldName.all({show_on_modal: true}).then (cf) ->
        $scope.publisherCustomFields = cf

      PublisherDetails.fillRateByMonth(id: $routeParams.id).then (data) ->
#        console.log data
#        console.log "11111111111111"

      PublisherDetails.dailyRevenueGraph(id: $routeParams.id).then (data) ->
        transformed = transformData data
        dailyRevenueChart(transformed)

      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_stages = settings.publisher_stages
        $scope.publisher_types = settings.publisher_types
        $scope.renewal_term_fields = settings.renewal_term_fields

    transformData = (data) ->
      result = {values: [], months: []}
      data.forEach (d) ->
        result.values.push(d.revenue)
        result.months.push({label: moment(d.date).format('MMM DD'), date: moment(d.date).format('YYYY-MM-DD')})
      result

    $scope.updatePublisher = (publisher) ->
      console.log(publisher)
      publisher.type_id = publisher.type.id
      publisher.renewal_term_id = publisher.renewal_term.id
      publisher.publisher_custom_field_attributes = publisher.publisher_custom_field_obj

      Publisher.update(id: $scope.currentPublisher.id, publisher: publisher).then (response) ->
        $rootScope.$broadcast 'updated_publisher_detail'

    $scope.deletePublisher = (publisher) ->
      if confirm('Are you sure you want to delete "' + publisher.name + '"?')
        Publisher.delete(id: publisher.id)

    $scope.updateMember = (member) ->
      PublisherMembers.update(id: member.id, owner: member.owner).then (res) ->
        $rootScope.$broadcast 'updated_publisher_detail'

    $scope.showLinkExistingUser = ->
      User.query().$promise.then (users) ->
        $scope.users = $filter('notIn')(users, $scope.currentPublisher.publisher_members, 'user_id')

    $scope.linkExistingUser = (selectedMember) ->
      $scope.userToLink = undefined
      PublisherMembers.create(id: selectedMember.id, publisher_id: $scope.currentPublisher.id).then (res) ->
        $rootScope.$broadcast 'updated_publisher_detail'

    $scope.showEditModal = (publisher) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_form.html'
        size: 'md'
        controller: 'PablisherActionsController'
        backdrop: 'static'
        keyboard: false
        resolve:
          publisher: ->
            angular.copy publisher

    dailyRevenueChart = (revenueData) ->
      return false if _.isEmpty(revenueData.months)

      chartId = "#daily-revenue-chart"
      chartContainer = angular.element(chartId + '-container')
      delay = 1000
      duration = 2000
      margin =
        top: 10
        left: 70
        right: 10
        bottom: 40
      minWidth = revenueData.months.length * 60
      width = chartContainer.width() - margin.left - margin.right
      width = minWidth if width < minWidth
      height = 400

      months = revenueData.months
      currentMonthIndex = _.findIndex months, {date: moment().format('YYYY-MM-DD')}
      colors = d3.scale.category10()
      dataset = revenueData

      svg = d3.select(chartId)
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .html('')
        .append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

      maxValue = (d3.max [dataset], (item) -> d3.max item.values) || 0
      yMax = maxValue * 1.2

      x = d3.scale.ordinal().domain([0..months.length - 1]).rangePoints([width / months.length, width - width / months.length])
      y = d3.scale.linear().domain([yMax || 1, 0]).rangeRound([0, height])

      xAxis = d3.svg.axis().scale(x).orient('bottom')
      .outerTickSize(0)
      .innerTickSize(0)
      .tickPadding(10)
      .tickFormat (v, i) ->
        tick = d3.select(this)
        tick.attr 'class', 'x-tick-text'
        if currentMonthIndex == v
          tick
            .style 'font-weight', 'bold'
            .style 'font-size', '14px'
        months[v].label

      yAxis = d3.svg.axis().scale(y).orient('left')
        .innerTickSize(-width)
        .tickPadding(10)
        .outerTickSize(0)
        .ticks(if yMax > 6 then 6 else yMax || 1)
        .tickFormat (v) -> $filter('formatMoney')(v)
      yAxis.tickValues([0]) if yMax == 0

      svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
      svg.append('g').attr('class', 'axis').call yAxis

      if currentMonthIndex && currentMonthIndex != -1
        svg.append('line')
          .attr('class', 'month-line')
          .attr 'x1', x(currentMonthIndex)
          .attr 'y1', height
          .attr 'x2', x(currentMonthIndex)
          .attr 'y2', height
          .transition()
          .delay(delay / 2)
          .duration(duration / 2)
          .ease('linear')
          .attr('y1', 0)

      graphLine = d3.svg.line()
      .x((value, i) -> x(i))
      .y((value, i) -> y(value))
      .defined((value, i) -> _.isNumber value)

      graphsContainer = svg.append('g').attr('class', 'graphs-container')

      graphs = graphsContainer.selectAll('.graph')
      .data([dataset])
      .enter()
      .append('path')
      .attr('class', 'graph')
      .attr 'stroke', "#ff7200"
      .attr 'd', -> graphLine(_.map months, -> 0)
      .transition()
      .duration(duration)
      .attr 'd', (d) -> graphLine(d.values)

    $scope.$on 'updated_publisher_detail', ->
      $scope.init()

    $scope.init()

]