class Item < ActiveRecord::Base
	has_many :order_items
	has_many :item_prices
end
