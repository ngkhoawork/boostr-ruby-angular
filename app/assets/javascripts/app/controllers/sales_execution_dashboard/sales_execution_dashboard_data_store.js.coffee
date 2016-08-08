@app.factory 'SalesExecutionDashboardDataStore',
  ['$rootScope',
   ($rootScope) ->
    DataStore = {}

    DataStore.optionsProductPipeline = {
      chart: {
        type: 'multiBarHorizontalChart',
        margin: {
          top: 20,
          right: 0,
          bottom: 70,
          left: 120
        },
        height: 250,
        x: (d) =>
          return d.label
        ,
        y: (d) =>
          return d.value
        ,

        groupSpacing: 0.2,
        showControls: false,
        stacked: true,
        showValues: true,
        duration: 500,
        xAxis: {
          showMaxMin: false
          tickFormat: (d) =>
            return if d.length > 14 then d.substr(0, 14) + '...' else d + '   '
        },
        yAxis: {
          tickPadding: 8,
          showMaxMin: false,
          tickFormat: (d) =>
            return if d > 10000 then '$' + d3.format(',.0f')(d/1000) + "k" else '$' + d3.format(',')(d)
        }
      }
    }

    DataStore.optionsQuarterForecast = [
      {
        chart: {
          type: 'multiBarChart',
          height: 300,
          dispatch: {
            renderEnd: (e) ->
              $rootScope.$emit('quarterForecastRendered1');
          },
          margin: {
            top: 20,
            right: 20,
            bottom: 60,
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
          xAxis: {
            axisLabel: "",
            ticks: 4,
            showMaxMin: false
          },
          yAxis: {
            axisLabel: "",
            showMaxMin: true,
            ticks: 8,
            tickFormat: (d) =>
              return if d > 10000 then '$' + d3.format(',.0f')(d/1000) + "k" else '$' + d3.format(',')(d)
          }
        }
      },
      {
        chart: {
          type: 'multiBarChart',
          height: 300,
          dispatch: {
            renderEnd: (e) ->
              $rootScope.$emit('quarterForecastRendered2');
          },
          margin: {
            top: 20,
            right: 20,
            bottom: 60,
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
          xAxis: {
            axisLabel: "",
            ticks: 4,
            showMaxMin: false
          },
          yAxis: {
            axisLabel: "",
            showMaxMin: true,
            ticks: 8,
            tickFormat: (d) =>
              return if d > 10000 then '$' + d3.format(',.0f')(d/1000) + "k" else '$' + d3.format(',')(d)
          }
        }
      }]

    DataStore.dataQuaterForecast = []

    DataStore.getOptionsProductPipeline = () ->
      return DataStore.optionsProductPipeline

    DataStore.getOptionsQuarterForecast = () ->
      return DataStore.optionsQuarterForecast


    DataStore.getGraphDataQuarterForecast = (index) ->
      return DataStore.dataQuaterForecast

    DataStore.setDataQuarterForecast = (data) ->
      probability_colors = [ { probability: "90", color: "#ca6a28"}, { probability: "75" , color: "#e2772e" }, { probability: "50" , color: "#ef9164" }, { probability: "25" , color: "#f3b29a" }, { probability: "10" , color: "#f6ccbe" }]
      DataStore.dataQuaterForecast = _.map data, (row, index) ->
        graphData = []
        series = 1
        graphData.push ({
          key: "Revenue",
          values: [
            {label: "weighted", value: row.revenue, series: series },
            {label: "un-weighted", value: row.revenue, series: series },
          ],
          color: "#92d050"
        })
        total_weighted = row.revenue
        total_unweighted = row.revenue
        series = series + 1
        _.each probability_colors, (item) ->
          color = item.color
          probability = item.probability
          stage = _.find row.stages, (o) ->
            return o.probability == parseInt(probability)
          if stage && row.weighted_pipeline_by_stage
            weighted_value = if row.weighted_pipeline_by_stage[stage.id] > 0 then row.weighted_pipeline_by_stage[stage.id] else 0
          else
            weighted_value = 0

          if stage && row.unweighted_pipeline_by_stage
            unweighted_value = if row.unweighted_pipeline_by_stage[stage.id] > 0 then row.unweighted_pipeline_by_stage[stage.id] else 0
          else
            unweighted_value = 0
          graphData.push ({
            key: probability + '%',
            values: [
              {label: "weighted", value: weighted_value, series: series},
              {label: "un-weighted", value: unweighted_value, series: series},
            ],
            color: color
          })
          total_weighted += weighted_value
          total_unweighted += unweighted_value
          series = series + 1


        quota_weighted = Math.max(row.quota, total_unweighted / 5 * 6)

        DataStore.optionsQuarterForecast[index].chart.multibar = { forceY: [0,0,quota_weighted] }

        return {
          graphData: graphData,
          quota: row.quota,
          maxValue: quota_weighted,
          revenue: row.revenue,
          weighted_pipeline: row.weighted_pipeline,
          percent_to_quota: row.percent_to_quota,
          new_deals_needed: row.new_deals_needed
        }
    return DataStore
  ]