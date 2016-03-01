class Location < ActiveRecord::Base
	belongs_to :company
	belongs_to :address
	has_many :orders

	def full_name
		"#{code} - #{company.name} - #{name}"
	end
end
