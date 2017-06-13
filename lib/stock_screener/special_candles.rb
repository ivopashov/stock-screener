module SpecialCandles
  extend self

  def shooting_star(ticker, start_date, backtrack, tail_body_ratio)
    records, starting_index = StockSnapshot.fetch ticker, start_date, backtrack

    for index in starting_index...(records.size)
      record = records[index]

      close_open_max = [record[:open], record[:close]].max
      high_to_close_open_max_difference = record[:high] - close_open_max
      open_close_difference = [record[:open], record[:close]].sort.each_cons(2).map { |a, b| b - a }.first

      previous_records =
        records.
        select { |r| r[:row] >= (record[:row] - backtrack) && r[:row] <= record[:row] }.
        sort { |x, y| x[:date] <=> y[:date] }

      closes = previous_records.map { |r| r[:close] }.each_cons(2).map { |a, b| b - a }

      if closes.all?(&:positive?) && record[:open] > record[:close] && ((high_to_close_open_max_difference / open_close_difference) > tail_body_ratio)
        p "Shooting star for #{record[:ticker]} on #{record[:date]}"
      end
    end
  end
end
