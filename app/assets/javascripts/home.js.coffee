contract_type = "Stock"

@get_ticker = (ticker, start_date, end_date) ->
  $.getJSON "/", (prices) ->
    console.log prices.ticker_prices
    load_pricing_chart(prices, ticker)
  return

load_pricing_chart = (prices, ticker) ->
  if contract_type is "Stock"
    stock_prices(prices, ticker)
  else if contract_type is "Bond"
    bond_prices(prices, ticker)
  else
    derivative_prices(prices, ticker)

stock_prices = (prices, ticker) ->    
  @chart = new AmCharts.AmStockChart()
  chart.pathToImages = "http://www.amcharts.com/lib/3/images/"

  # create dataset for ticker
  dataSet = new AmCharts.DataSet()
  dataSet.title = ticker
  dataSet.fieldMappings  = [ 
          {
            fromField: "open"
            toField: "open"
          }
          {
            fromField: "close"
            toField: "close"
          }
          {
            fromField: "high"
            toField: "high"
          }
          {
            fromField: "low"
            toField: "low"
          }
          {
            fromField: "volume"
            toField: "volume"
          }
  ]
  
  dataSet.color = "#7f8da9"
  dataSet.dataProvider  = prices.ticker_prices
  dataSet.categoryField = "traded_on"
  chart.dataSets.push(dataSet)
  
  # Add stock panels
  stockPanel_candle = new AmCharts.StockPanel();
  stockPanel_candle.title = "#{contract_type} Price"
  stockPanel_candle.showCategoryAxis = false
  stockPanel_candle.percentHeight = 60
  stockPanel_candle.categoryAxis.dashLength = 5
  stockPanel_candle.drawingIconsEnabled = true
  chart.addPanel(stockPanel_candle)

  # Candle stick graph  
  graph = new AmCharts.StockGraph()
  graph.type = "candlestick"
  graph.id = "g1"
  graph.openField   = "open"
  graph.closeField  = "close"
  graph.highField   = "high"
  graph.lowField    = "low"
  graph.valueField  = "close"
  graph.lineColor   = "#7f8da9"
  graph.fillColors  = "#7f8da9"
  graph.negativeLineColor = "#db4c3c"
  graph.negativeFillColors = "#db4c3c"
  graph.fillAlphas = 1
  graph.useDataSetColors = false
  graph.comparable = true
  graph.compareField = "close"
  graph.showBalloon = true
  graph.balloonText = "open:<b>[[open]]</b><br>close:<b>[[close]]</b><br>low:<b>[[low]]</b><br>high:<b>[[high]]</b>"
  stockPanel_candle.addStockGraph(graph)
 
  chart.chartScrollbarSettings.graph = "g1"
  chart.chartScrollbarSettings.graphType = "line"
  chart.chartScrollbarSettings.usePeriod = "WW"
  

  # Legend for Candlestick graph
  legend = new AmCharts.StockLegend()
  legend.periodValueTextRegular = "[[value.close]]"
  legend.periodValueTextComparing = "[[percents.value.close]]%"
  legend.position = "top"
  legend.title = "Stock Price"
  stockPanel_candle.addLegend(legend)

  # Volume graph
  stockPanel_volume = new AmCharts.StockPanel()
  stockPanel_volume.title = "Stock Volume"
  stockPanel_volume.showCategoryAxis = true
  stockPanel_volume.percentHeight = 20
  stockPanel_volume.categoryAxis.dashLength = 5
  stockPanel_volume.marginTop = 1
  chart.addPanel(stockPanel_volume)

  graph = new AmCharts.StockGraph()
  graph.valueField = "volume"
  graph.type = "column"
  graph.showBalloon = false
  graph.fillAlphas = 1
  stockPanel_volume.addStockGraph(graph)
  
  legend = new AmCharts.StockLegend()
  legend.markerType = "none"
  legend.markerSize = 0
  legend.periodValueTextRegular = "[[value.volume]]"
  legend.position = "top"
  legend.title = "Volume"
  stockPanel_volume.addLegend(legend)
  # volume graph ends

  # Enable pan events
  panelsSettings = new AmCharts.PanelsSettings();
  panelsSettings.panEventsEnabled = true;
  chart.panelsSettings = panelsSettings;

  cursorSettings = new AmCharts.ChartCursorSettings();
  cursorSettings.valueBalloonsEnabled = true;
  chart.chartCursorSettings = cursorSettings;

  periodSelector = new AmCharts.PeriodSelector()
  periodSelector.position = "bottom"
  periodSelector.periods =  [
    {
      period: "DD"
      count: 10
      label: "10 days"
    }
    {
      period: "MM"
      count: 1
      label: "1 month"
    }
    {
      period: "YYYY"
      selected: true
      count: 1
      label: "1 year"
    }
    {
      period: "YTD"
      label: "YTD"
    }
    {
      period: "MAX"
      label: "MAX"
    }
  ]
  chart.periodSelector = periodSelector

  chart.categoryAxesSettings.maxSeries = 365

  dataSetSelector = new AmCharts.DataSetSelector()
  dataSetSelector.position = "top"
  chart.dataSetSelector = dataSetSelector
  
  chart.write("stock-price")
  return

