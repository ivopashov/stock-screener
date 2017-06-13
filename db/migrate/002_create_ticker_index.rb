class CreateTickerIndex < ActiveRecord::Migration[5.0]
  def self.change
    add_index :stock_snapshots, :ticker
  end
end
