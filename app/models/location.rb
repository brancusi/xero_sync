class Location < ActiveRecord::Base
	include AASM

	belongs_to :company
	belongs_to :address
	has_many :orders, :dependent => :destroy, autosave: true
	has_many :visit_windows, :dependent => :destroy, autosave: true

	has_many :visit_days, :dependent => :destroy, autosave: true
	has_many :item_desires, :dependent => :destroy, autosave: true

	scope :scheduled_for_delivery_on?, ->(day) { where(:visit_days => {:day => day-1, :enabled => true}).joins(:visit_days).distinct }

	enum location_state: [ :pending, :synced ]
	aasm :location, :column => :location_state, :skip_validation_on_save => true do
    state :pending, :initial => true
    state :synced

		event :mark_pending do
      transitions :from => :pending, :to => :pending
      transitions :from => :synced, :to => :pending
    end

    event :mark_synced do
      transitions :from => :pending, :to => :synced
      transitions :from => :synced, :to => :synced
    end
  end

	def has_sales_order_for_date? (delivery_date)
		orders.where(delivery_date:delivery_date, order_type:'sales-order').present?
	end

	def xero_name
		"#{code} - #{company.name} - #{name}"
	end

end
