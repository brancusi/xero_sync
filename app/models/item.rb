class Item < ActiveRecord::Base
	has_many :order_items, :dependent => :destroy, autosave: true
	has_many :item_prices, :dependent => :destroy, autosave: true
end
