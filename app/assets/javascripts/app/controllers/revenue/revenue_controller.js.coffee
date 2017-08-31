@app.controller 'RevenueController',
	['$scope', '$document', '$modal', '$filter', '$routeParams', '$route', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem'
	( $scope,   $document,   $modal,   $filter,   $routeParams,   $route,   $location,   $q,   IO,   TempIO,   DisplayLineItem ) ->

		currentYear = moment().year()
		$scope.isLoading = false
		$scope.revenue = []
		$scope.revenueFilters = [
			{name: 'IOs', value: ''}
			{name: 'No-Match IOs', value: 'no-match'}
			{name: 'Programmatic', value: 'programmatic'}
			{name: 'Upside Revenues', value: 'upside'}
			{name: 'At Risk Revenues', value: 'risk'}
		]
		$scope.pacingAlertsFilters = [
			{name: 'My Lines', value: 'my'}
			{name: 'My Team\'s Lines', value: 'teammates'}
			{name: 'All Lines', value: 'all'}
		]

		$scope.filter =
			page: 1
			revenue: $routeParams.filter || ''
			pacing: $routeParams.io_owner || ''
			search: ''
			date:
				startDate: moment().year(currentYear).startOf('year')
				endDate: moment().year(currentYear).endOf('year')

		$scope.datePicker =
			toString: () ->
				date = $scope.filter.date
				if !date.startDate || !date.endDate then return false
				date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
			apply: ->
				$scope.applyFilter()

		$scope.setFilter = (key, val) ->
			$scope.filter[key] = val
			switch key
				when 'revenue', 'pacing'
					$location.search({filter: $scope.filter.revenue, io_owner: $scope.filter.pacing})
					$scope.filter.page = 1
					$scope.revenue = []
			$scope.applyFilter()

		$scope.applyFilter = ->
			$scope.isLoading = true
			getData(getQuery())

		getQuery = ->
			f = $scope.filter
			query = {}
			query.page = f.page
			query.filter = f.revenue
			query.search = f.search if f.search
			if f.date.startDate && f.date.endDate
				query.start_date = f.date.startDate.toDate()
				query.end_date = f.date.endDate.toDate()
			query


		getData = (query) ->
			switch query.filter
				when 'no-match'
					TempIO.all(query).then (tempIOs) ->
						setRevenue tempIOs
				when 'upside', 'risk'
					query.io_owner = $scope.filter.pacing if $scope.filter.pacing #adding extra param
					DisplayLineItem.all(query).then (ios) ->
						setRevenue ios
				else
					IO.all(query).then (ios) ->
						setRevenue ios

		$scope.loadMoreRevenues = ->
			$scope.filter.page++
			$scope.applyFilter()

		parseBudget = (data) ->
			data = _.map data, (item) ->
				item.budget = parseInt item.budget  if item.budget
				item.budget_loc = parseInt item.budget_loc  if item.budget_loc
				item

		setRevenue = (data) ->
			parseBudget data
			$scope.revenue = data
			$scope.isLoading = false

		$scope.showIOEditModal = (io) ->
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/io_form.html'
				size: 'md'
				controller: 'IOEditController'
				backdrop: 'static'
				keyboard: false
				resolve:
					io: ->
						io
			.result.then (updated_io) ->
				if (updated_io)
					$scope.init();

		$scope.showAssignIOModal = (tempIO) ->
			$scope.modalInstance = $modal.open
				templateUrl: 'modals/io_assign_form.html'
				size: 'lg'
				controller: 'IOAssignController'
				backdrop: 'static'
				keyboard: false
				resolve:
					tempIO: ->
						tempIO
			.result.then (updated_temp_io) ->
				if (updated_temp_io)
					$scope.init();

		$scope.$on 'updated_ios', ->
			$scope.init()
			IO.query().$promise

		$scope.deleteIo = (io, $event) ->
			$event.stopPropagation();
			if confirm('Are you sure you want to delete "' + io.name + '"?')
				IO.delete io, ->
					$location.path('/revenue')

		$scope.applyFilter()
	]
