module Volume
  extend self

  def unusually_high(ticker, start_date, backtrack, percentage_threshold)
    records, starting_index = StockSnapshot.fetch ticker, start_date, backtrack

    for index in starting_index...(records.size)
      record = records[index]
      volumes = records[(index - backtrack)..index].map { |r| r[:volume] }.sort.reverse

      next if record[:volume] != volumes[0]
      percentage_higher_than_second_best = (((record[:volume] / volumes[1]) - 1) * 100).round(2)

      if percentage_higher_than_second_best > percentage_threshold
        p "#{ticker} on #{record[:date]} has high volume. It is #{percentage_higher_than_second_best}% higher than the second biggest"
      end
    end
  end
end
