@app.factory 'MonthlyForecastsDataStore',
  ['$rootScope',
    ($rootScope) ->
      DataStore = {}

      DataStore.options = {
        chart: {
          type: 'multiBarChart',
          height: 350,
          dispatch: {
            renderEnd: (e) ->
              $rootScope.$emit('monthlyForecastRendered')
          },
          margin: {
            top: 20,
            right: 20,
            bottom: 80,
            left: 70
          },
          showControls: false,
          x: (d) =>
            return d.label
          ,
          y: (d) =>
            return d.value
          ,
          average: (d) ->
            return d.mean/100
          ,
        #      clipEdge: true,
          duration: 500,
          stacked: true,
          showValues: true,
          groupSpacing: 0.5,
          reduceXTicks: false,
          xAxis: {
            axisLabel: "",
            ticks: 4,
            showMaxMin: false
          },
          yAxis: {
            axisLabel: "",
            showMaxMin: true,
            ticks: 4,
            tickFormat: (d) =>
              return if d > 10000 then '$' + d3.format(',.0f')(d/1000) + "k" else '$' + d3.format(',')(d)
          }
        }
      }


      DataStore.data = {}

      DataStore.getOptions = () ->
        return DataStore.options

      DataStore.getData = (dataType) ->
        return DataStore.data[dataType]

      DataStore.setData = (data) ->
        probability_colors = [ { probability: "100", color: "#1976bb"}, { probability: "90", color: "#3996db"}, { probability: "75" , color: "#52a1e2" }, { probability: "50" , color: "#7ab9e9" }, { probability: "25" , color: "#a4d0f0" }, { probability: "10" , color: "#d2e8f8" }]

        graphDataWeighted = []
        graphDataUnweighted = []
        series = 1
        values = []

        total_weighted = 0
        total_unweighted = 0

        _.each data.months, (date) ->
          values.push({label: date, value: data.forecast.monthly_revenue[date], series: series })
          total_weighted += data.forecast.monthly_revenue[date]
          total_unweighted += data.forecast.monthly_revenue[date]

        graphDataWeighted.push ({
          key: "Revenue",
          values: values,
          color: "#9aca48"
        })
        graphDataUnweighted.push ({
          key: "Revenue",
          values: values,
          color: "#9aca48"
        })

        series = series + 1
        stages = angular.copy(data.forecast.stages)
        stages = _.sortBy stages, (stage) ->
          return -stage.probability

        _.each stages, (stage) ->
          probability = stage.probability
          red = parseInt(210 - 185 * probability / 100)
          green = parseInt(232 - 114 * probability / 100)
          blue = parseInt(248 - 61 * probability / 100)
          color = "#" + ((1 << 24) + (red << 16) + (green << 8) + blue).toString(16).slice(1);
          values = []

          if stage && data.forecast.monthly_weighted_pipeline_by_stage && data.forecast.monthly_weighted_pipeline_by_stage[stage.id]
            _.each data.months, (date) ->
              if data.forecast.monthly_weighted_pipeline_by_stage[stage.id][date]
                values.push({label: date, value: data.forecast.monthly_weighted_pipeline_by_stage[stage.id][date], series: series})
              else
                values.push({label: date, value: 0, series: series})
          else
            _.each data.months, (date) ->
              values.push({label: date, value: 0, series: series})

          graphDataWeighted.push ({
            key: probability + '%',
            values: values,
            color: color
          })

          values = []

          if stage && data.forecast.monthly_unweighted_pipeline_by_stage && data.forecast.monthly_unweighted_pipeline_by_stage[stage.id]
            _.each data.months, (date) ->
              if data.forecast.monthly_unweighted_pipeline_by_stage[stage.id][date]
                values.push({label: date, value: data.forecast.monthly_unweighted_pipeline_by_stage[stage.id][date], series: series})
              else
                values.push({label: date, value: 0, series: series})
          else
            _.each data.months, (date) ->
              values.push({label: date, value: 0, series: series})

          graphDataUnweighted.push ({
            key: probability + '%',
            values: values,
            color: color
          })

          series = series + 1
        DataStore.data = {
          weighted: graphDataWeighted,
          unweighted: graphDataUnweighted,
        }
      return DataStore
  ]