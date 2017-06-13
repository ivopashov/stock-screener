module SMA
  extend self

  def death_cross(ticker, start_date)
    records, starting_index = StockSnapshot.fetch ticker, start_date, 1

    for index in starting_index...(records.size)
      record = records[index]
      next if record[:sma50].zero? || record[:sma200].zero?

      sma50_lte_sma200 = record[:sma50] <= record[:sma200]
      previous_record_sma50_gt_sma200 = records[index - 1][:sma50] > records[index - 1][:sma200]
      p "death cross for #{record[:ticker]} on #{record[:date]}" if sma50_lte_sma200 && previous_record_sma50_gt_sma200
    end
  end

  def golden_cross(ticker, start_date)
    records, starting_index = StockSnapshot.fetch ticker, start_date, 1

    for index in starting_index...(records.size)
      record = records[index]
      next if record[:sma50].zero? || record[:sma200].zero?

      sma50_gte_sma200 = record[:sma50] >= record[:sma200]
      previous_record_sma50_lt_sma200 = records[index - 1][:sma50] < records[index - 1][:sma200]
      p "golden cross for #{record[:ticker]} on #{record[:date]}" if sma50_gte_sma200 && previous_record_sma50_lt_sma200
    end
  end
end
