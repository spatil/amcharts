class HomeController < ApplicationController
  def index
    prices = DailyPrice.where(ticker: "60_40_VT_BND")
    respond_to do |format|
      format.json {
        render json: 
          {
            ticker_prices: prices
          }
        }
      format.html 
    end
  end
end
