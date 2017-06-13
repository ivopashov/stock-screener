class CreateStockSnapshot < ActiveRecord::Migration[5.0]
  def self.up
    create_table :stock_snapshots do |t|
      t.string :ticker, null: false
      t.float :close
      t.float :volume
      t.float :open
      t.float :high
      t.float :low
      t.date :date
      t.float :sma20, default: 0
      t.float :sma50, default: 0
      t.float :sma200, default: 0
      t.float :rsi, default: 0
    end
  end

  def self.down
    drop_table :stock_snapshots
  end
end
