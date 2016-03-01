class Order < ActiveRecord::Base
  belongs_to :location
  has_many :order_items, -> { joins(:item).order('position') }

  def price_for_item(item)
		location.company.price_tier.price_for_item(item)
	end
end
