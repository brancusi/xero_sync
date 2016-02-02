class Client < ActiveRecord::Base

	validates :code, presence: true
	validates :company, presence: true

	has_many :sales_orders, :dependent => :destroy, autosave: true
	has_many :visit_windows, :dependent => :destroy, autosave: true

	has_many :client_visit_days, :dependent => :destroy, autosave: true
	has_many :client_item_desires, :dependent => :destroy, autosave: true

	belongs_to :price_tier

	def full_name
		if(nickname.present?)
			return "#{code} - #{company} - #{nickname}"
		else
			return "#{code} - #{company}"
		end
	end

end
