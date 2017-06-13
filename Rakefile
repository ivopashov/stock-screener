ENV['RAILS_ENV'] ||= 'development'

require 'tasks/standalone_migrations'
require_relative 'lib/stock_screener'

ActiveRecord::Base.schema_format = :sql
StandaloneMigrations::Tasks.load_tasks

namespace :bootstrap do
  desc 'Initialize ticker'
  task tickers: :environment do
    tickers = ENV['TICKERS'].present? ? ENV['TICKERS'].split(',') : Tickers::Sp500
    start_date = ENV['START_DATE'] ? Date.parse(ENV['START_DATE']) : (Date.today - 365)
    thread_count = ENV['THREAD_COUNT'] || 20

    queue = Queue.new
    tickers.each { |ticker| queue.push ticker }

    threads = []

    thread_count.times do
      threads << Thread.new do
        until queue.empty?
          ticker = queue.pop(true) rescue nil
          if ticker
            Bootstraper.seed_for(ticker, start_date)
          end
        end
      end
    end

    threads.map(&:join)
  end

  task rsi_14: :environment do
    tickers = ENV['TICKERS'].split(',')
    tickers.each do |ticker|
      Bootstraper.calculate_rsi_14(ticker)
    end
  end

  task smas: :environment do
    tickers = ENV['TICKERS'].split(',')
    tickers.each do |ticker|
      Bootstraper.calculate_smas(ticker)
    end
  end
end

namespace :sma do
  task death_cross: :environment do
    tickers = ENV['TICKERS']&.split(',') || Tickers::Sp500
    start_date = ENV['START_DATE'] ? Date.parse(ENV['START_DATE']) : (Date.today - 10)

    tickers.each do |ticker|
      SMA.death_cross ticker, start_date
    end
  end

  task golden_cross: :environment do
    tickers = ENV['TICKERS']&.split(',') || Tickers::Sp500
    start_date = ENV['START_DATE'] ? Date.parse(ENV['START_DATE']) : (Date.today - 10)

    tickers.each do |ticker|
      SMA.golden_cross ticker, start_date
    end
  end
end

namespace :volume do
  task unusually_high: :environment do
    tickers = ENV['TICKERS']&.split(',') || Tickers::Sp500
    start_date = ENV['START_DATE'] ? Date.parse(ENV['START_DATE']) : (Date.today - 10)
    backtrack = ENV['BACKTRACK']&.to_i || 10
    percentage_threshold = ENV['PERCENTAGE_THRESHOLD']&.to_i || 10

    tickers.each do |ticker|
      Volume.unusually_high ticker, start_date, backtrack, percentage_threshold
    end
  end
end

namespace :special_candles do
  task shooting_star: :environment do
    tickers = ENV['TICKERS']&.split(',') || Tickers::Sp500
    start_date = ENV['START_DATE'] ? Date.parse(ENV['START_DATE']) : (Date.today - 10)
    backtrack = ENV['BACKTRACK'] ? ENV['BACKTRACK'].to_i : 4
    tail_body_ratio = ENV['TAIL_BODY_RATIO'] ? ENV['TAIL_BODY_RATIO'].to_i : 3

    tickers.each do |ticker|
      SpecialCandles.shooting_star ticker, start_date, backtrack, tail_body_ratio
    end
  end
end
