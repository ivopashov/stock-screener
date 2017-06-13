class StockSnapshot < ActiveRecord::Base
  def self.fetch(ticker, start_date, backtrack)
    found_date = start_date

    loop do
      if where(ticker: ticker, date: found_date).first
        break
      else
        found_date -= 1
      end
    end

    fetch_query =
      ActiveRecord::Base.send :sanitize_sql_array, [<<~SQL, ticker: ticker, found_date: found_date, backtrack: backtrack]
        WITH stock_info AS (
          SELECT row_number() OVER (ORDER BY date) AS row, * FROM stock_snapshots WHERE ticker = :ticker
        ),
        row_number_for_date AS (
          SELECT row FROM stock_info WHERE date = :found_date
        )
        SELECT * FROM stock_info WHERE row >= ((SELECT row FROM row_number_for_date) - :backtrack);
      SQL

    records =
      ActiveRecord::Base.connection.execute(fetch_query).to_a.map { |record| record.with_indifferent_access }

    index_of_start_date =
      records.find_index { |record| record[:date] == found_date.to_s }

    [records, index_of_start_date]
  end
end
