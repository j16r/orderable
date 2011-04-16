require 'helper'

MySQLRecord = Class.new ActiveRecord::Base
MySQLRecord.establish_connection(:adapter => 'mysql', :host => 'localhost', :database => 'orderable_test')

MySQLRecord.connection.drop_table(:items)
MySQLRecord.connection.create_table :items do |t|
  t.string :name
  t.integer :order_position
end

class Item < MySQLRecord
  set_table_name 'items'
  include Orderable
  orderable_field_is :order_position
end

class TestOrderable < Test::Unit::TestCase

  def setup
    stub(Orderable).adapter.returns 'mysql'
    @items = [
      Item.create(:name => 'item1'),
      Item.create(:name => 'item2'),
      Item.create(:name => 'item3'),
      Item.create(:name => 'item4')]
  end

  def test_default_order
    assert_equal Item.in_order.all.map(&:name), ['item1', 'item2', 'item3', 'item4']
  end

  def test_updated_order
    Item.update_order \
      @items[3].id,
      @items[1].id,
      @items[2].id,
      @items[0].id
    assert_equal Item.in_order.all.map(&:name), ['item4', 'item2', 'item3', 'item1']
  end

end
