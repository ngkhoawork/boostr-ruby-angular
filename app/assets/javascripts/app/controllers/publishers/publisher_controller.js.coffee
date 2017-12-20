@app.controller 'PablisherController', [
  '$scope', '$modal', '$filter', '$routeParams', 'Publisher', 'PublisherDetails', 'PublisherMembers', '$rootScope', 'User', 'PublisherCustomFieldName', 'PublisherAttachment', 'PublisherContact'
  ($scope,   $modal,   $filter,   $routeParams,   Publisher,   PublisherDetails, PublisherMembers, $rootScope, User, PublisherCustomFieldName, PublisherAttachment, PublisherContact) ->

    $scope.currentPublisher = {}

    $scope.init = ->
      $scope.getCurrentPublisher()
      $scope.getContactsAndMembers()
      $scope.getCustomFields()
      $scope.getDailyRevenueGraph()
      $scope.getPublisherSettings()
      $scope.getDealFiles()

    $scope._scope = -> this

    $scope.isUrlValid = (url) ->
      regexp = /^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?/
      regexp.test url

    $scope.getUrlHostname = (url) ->
      a = document.createElement 'a'
      a.href = $scope.fixUrl url
      a.hostname

    $scope.fixUrl = (url) ->
      if url && url.search('//') == -1 then return '//' + url else url

    $scope.getDealFiles = () ->
      PublisherAttachment.list(publisher_id: $routeParams.id, type: "publisher").then (res) ->
        $scope.dealFiles = res

    $scope.getCurrentPublisher = ->
      PublisherDetails.getPublisher(id: $routeParams.id).then (publisher) ->
        $scope.currentPublisher = publisher

    $scope.getContactsAndMembers = ->
      PublisherDetails.associations(id: $routeParams.id).then (association) ->
        $scope.memberRoles = association.member_roles
        $scope.contacts = association.contacts
        $scope.publisherMembers = association.members

    $scope.getCustomFields = ->
      PublisherCustomFieldName.all().then (cf) ->
        $scope.publisherCustomFields = cf

    $scope.getDailyRevenueGraph = ->
      PublisherDetails.dailyRevenueGraph(id: $routeParams.id).then (data) ->
        transformed = transformData data
        dailyRevenueChart(transformed)

    $scope.getPublisherSettings = ->
      Publisher.publisherSettings().then (settings) ->
        $scope.publisher_stages = settings.publisher_stages
        $scope.publisher_types = settings.publisher_types
        $scope.renewal_term_fields = settings.renewal_term_fields

    transformData = (data) ->
      result = {values: [], months: [], alternative: []}
      data.forEach (d) ->
        result.values.push(d.revenue)
        result.months.push({label: moment(d.date).format('MMM DD'), date: moment(d.date).format('YYYY-MM-DD')})
        result.alternative.push({date: moment(d.date).format("D-MMM-YY"), close: d.revenue})
      result

    $scope.updatePublisher = (publisher) ->

      publisher.type_id = publisher.type.id if publisher.type
      publisher.renewal_term_id = publisher.renewal_term.id if publisher.renewal_term
      publisher.publisher_stage_id = publisher.publisher_stage.id if publisher.publisher_stage
      publisher.publisher_custom_field_attributes = publisher.publisher_custom_field_obj

      Publisher.update(id: $scope.currentPublisher.id, publisher: publisher).then (response) ->
        $rootScope.$broadcast 'updated_publisher_detail'

    $scope.deletePublisher = (publisher) ->
      if confirm('Are you sure you want to delete "' + publisher.name + '"?')
        Publisher.delete(id: publisher.id)

    $scope.updateMember = (member) ->
      params = {}
      params.owner = member.owner
      if member.member_role
        params.role_id = member.member_role.id

      PublisherMembers.update(id: member.id, publisher_member: params).then (res) ->
        $rootScope.$broadcast 'updated_publisher_detail'

    $scope.deleteMember = (member) ->
      if confirm('Are you sure you want to delete "' +  member.name + '"?')
        PublisherMembers.delete(id: member.id).then (res) ->
          $rootScope.$broadcast 'updated_publisher_detail'

    $scope.deleteContact = (contact) ->
      if confirm('Are you sure you want to delete "' +  contact.name + '"?')
        PublisherContact.delete(id: contact.id).then (res) ->
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

    $scope.addContact = ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_contact_form.html'
        size: 'md'
        controller: 'PublisherContactController'
        backdrop: 'static'
        keyboard: false
        resolve:
          contact: ->
            {}

    $scope.editContact = (contact) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/publisher_contact_form.html'
        size: 'md'
        controller: 'PublisherContactController'
        backdrop: 'static'
        keyboard: false
        resolve:
          contact: ->
            angular.copy contact

    dailyRevenueChart = (revenueData) ->
      return false if _.isEmpty(revenueData.months)

      chartId = "#daily-revenue-chart"
      chartContainer = angular.element(chartId + '-container')
      delay = 1000
      duration = 2000
      margin =
        top: 30
        right: 20
        bottom: 30
        left: 50
      minWidth = revenueData.months.length * 10
      width = chartContainer.width() - margin.left - margin.right
      width = minWidth if width < minWidth
      height = 400
      parseDate = d3.time.format('%d-%b-%y').parse
      formatTime = d3.time.format('%e %B')

      x = d3.time.scale().range([
        0
        width
      ])
      y = d3.scale.linear().range([
        height
        0
      ])

      xAxis = d3.svg.axis()
        .scale(x)
        .orient('bottom')
        .outerTickSize(0)
        .innerTickSize(0)
        .tickPadding(10)
        .tickFormat (v, i) ->
          tick = d3.select(this)
          tick.attr 'class', 'x-tick-text'
          return moment(v).format('MMM DD')

      yAxis = d3.svg.axis()
        .scale(y)
        .orient('left')
        .innerTickSize(-width)
        .tickPadding(10)
        .outerTickSize(0)
        .tickFormat (v) -> $filter('formatMoney')(v)

      valueline = d3.svg.line().x((d) ->
        x d.date
      ).y((d) ->
        y d.close
      )

      div = d3.select("#daily-revenue-chart-container").append('div').attr('class', 'tooltip').style('opacity', 0)

      svg = d3.select(chartId)
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .style('height', 'auto')
        .html('')
        .append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

      revenueData.alternative.forEach (data) ->
        data.date = parseDate(data.date)
        data.close = +data.close

        x.domain d3.extent(revenueData.alternative, (d) ->
          d.date
        )
        y.domain [
          0
          d3.max(revenueData.alternative, (d) ->
            d.close
          )
        ]

      svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
      svg.append('g').attr('class', 'axis').call yAxis

      svg.append('path').attr('class', 'line')
        .attr('d', valueline(revenueData.alternative))
        .transition()
        .delay(delay / 2)
        .duration(duration / 2)

      svg.selectAll('dot').data(revenueData.alternative).enter().append('circle').attr('r', 4).attr('cx', (d) ->
        x d.date
      ).attr('cy', (d) ->
        y d.close
      ).on('mouseover', (d) ->
        div.transition().duration(200).style 'opacity', .9
        matrix = @getScreenCTM().translate(+@getAttribute('cx'), +@getAttribute('cy'))

        div.html("<p>" + moment(d.date).format('MMM DD') + "</p>" + "<span>" + $filter('formatMoney')(d.close) + "</span>")
          .style('left', window.pageXOffset + matrix.e + - 30 + 'px')
          .style 'top', window.pageYOffset + matrix.f - 230 + 'px'
        return
      ).on 'mouseout', (d) ->
        div.transition().duration(500).style 'opacity', 0
        return

    $scope.$on 'updated_publisher_detail', ->
      $scope.init()

    $scope.init()

]