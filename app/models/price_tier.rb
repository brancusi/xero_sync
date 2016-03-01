class PriceTier < ActiveRecord::Base
	has_many :item_prices
	has_many :companies

	def price_for_item(item)
		item_prices.find_by(item:item).price
	end
end
