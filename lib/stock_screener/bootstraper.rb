require 'rest-client'

module Bootstraper
  extend self

  def seed_for(ticker, start_date)
    p "Seeding for: #{ticker}"

    today = Date.today
    end_period = today.to_time.to_i
    start_period = start_date.to_time.to_i

    url = "https://query1.finance.yahoo.com/v7/finance/chart/#{ticker}?period2=#{end_period}&period1=#{start_period}&interval=1d&indicators=quote&includeTimestamps=true&includePrePost=false&corsDomain=finance.yahoo.com"

    result = JSON.parse RestClient.get url

    result['chart']['result'].first['timestamp'].map { |t| Time.at(t).utc.to_date }.each_with_index do |date, index|
      volume = result['chart']['result'].first['indicators']['quote'].first['volume'][index]
      close = result['chart']['result'].first['indicators']['quote'].first['close'][index]
      open = result['chart']['result'].first['indicators']['quote'].first['open'][index]
      high = result['chart']['result'].first['indicators']['quote'].first['high'][index]
      low = result['chart']['result'].first['indicators']['quote'].first['low'][index]
      stock_snapshot = StockSnapshot.where(ticker: ticker, date: date).first

      if stock_snapshot
        stock_snapshot.update! close: close, volume: volume, open: open, high: high, low: low
      else
        StockSnapshot.create! ticker: ticker, close: close, volume: volume, open: open, high: high, low: low, date: date
      end
    end

    calculate_smas ticker
    calculate_rsi_14 ticker
  end

  def calculate_smas(ticker)
    stock_records = StockSnapshot.where(ticker: ticker).order(date: :asc).to_a

    stock_records.each_with_index do |stock_record, index|
      batch_of_twenty = stock_records[(index - 20)...index]
      batch_of_fifty = stock_records[(index - 50)...index]
      batch_of_two_hundred = stock_records[(index - 200)...index]

      stock_record.sma20 = (batch_of_twenty.map(&:close).sum / 20).round(2) if batch_of_twenty.size == 20
      stock_record.sma50 = (batch_of_fifty.map(&:close).sum / 50).round(2) if batch_of_fifty.size == 50
      stock_record.sma200 = (batch_of_two_hundred.map(&:close).sum / 200).round(2) if batch_of_two_hundred.size == 200

      stock_record.save!
    end
  end

  def calculate_rsi_14(ticker)
    stock_records = StockSnapshot.where(ticker: ticker).order(date: :asc).to_a

    stock_records.each_with_index do |stock_record, index|
      rsi_subset = stock_records[(index - 14)..index].pluck :close
      next unless rsi_subset.size == 15

      gains, losses = rsi_subset.each_cons(2).map { |a, b| b - a }.partition(&:positive?)

      losses = losses.map(&:abs)
      average_gain = gains.sum / 14
      average_loss = losses.sum / 14
      rsi = average_loss == 0 ? 0 : (100 - (100 / (1 + (average_gain / average_loss))))
      stock_record.rsi = rsi.to_i
      stock_record.save!
    end
  end
end
