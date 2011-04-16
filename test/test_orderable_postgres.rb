require 'helper'

PostgreSQLRecord = Class.new ActiveRecord::Base
PostgreSQLRecord.establish_connection(:adapter => 'postgresql', :host => 'localhost', :database => 'orderable_test')

PostgreSQLRecord.connection.drop_table(:items)
PostgreSQLRecord.connection.create_table :items do |t|
  t.string :name
  t.integer :order_position
end

class PSQLItem < PostgreSQLRecord
  set_table_name 'items'
  include Orderable
  orderable_field_is :order_position
end

class TestOrderablePostgres < Test::Unit::TestCase

  def setup
    stub(Orderable).adapter.returns 'postgres'
    @items = [
      PSQLItem.create(:name => 'item1'),
      PSQLItem.create(:name => 'item2'),
      PSQLItem.create(:name => 'item3'),
      PSQLItem.create(:name => 'item4')]
  end

  def teardown
    @items.each(&:delete)
  end

  def test_default_order
    assert_equal ['item1', 'item2', 'item3', 'item4'], PSQLItem.in_order.all.map(&:name)
  end

  def test_updated_order
    PSQLItem.update_order \
      @items[3].id,
      @items[1].id,
      @items[2].id,
      @items[0].id
    assert_equal ['item4', 'item2', 'item3', 'item1'], PSQLItem.in_order.all.map(&:name)
  end

end
