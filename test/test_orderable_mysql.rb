require 'helper'

MySQLRecord = Class.new ActiveRecord::Base
MySQLRecord.establish_connection(:adapter => 'mysql2', :host => 'localhost', :database => 'orderable_test')

MySQLRecord.connection.drop_table(:items) rescue Mysql2::Error
MySQLRecord.connection.create_table :items do |t|
  t.string :name
  t.integer :order_position
end

class MySQLItem < MySQLRecord
  set_table_name 'items'
  include Orderable
  orderable_field_is :order_position
end

class TestOrderableMySQL < Test::Unit::TestCase

  def setup
    stub(Orderable).adapter.returns 'mysql'
    @items = [
      MySQLItem.create(:name => 'item1'),
      MySQLItem.create(:name => 'item2'),
      MySQLItem.create(:name => 'item3'),
      MySQLItem.create(:name => 'item4')]
  end

  def teardown
    @items.each(&:delete)
  end

  def test_default_order
    assert_equal ['item1', 'item2', 'item3', 'item4'], MySQLItem.in_order.all.map(&:name)
  end

  def test_updated_order
    MySQLItem.update_order \
      @items[3].id,
      @items[1].id,
      @items[2].id,
      @items[0].id
    assert_equal ['item4', 'item2', 'item3', 'item1'], MySQLItem.in_order.all.map(&:name)
  end

end
