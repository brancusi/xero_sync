class Company < ActiveRecord::Base
	has_many :locations
	belongs_to :price_tier
end
