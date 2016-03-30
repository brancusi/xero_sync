class Item < ActiveRecord::Base
	include AASM

	validates :name, presence: true

	has_many :order_items, :dependent => :destroy, autosave: true
	has_many :item_prices, :dependent => :destroy, autosave: true
	has_many :item_desires, :dependent => :destroy, autosave: true

	enum item_state: [ :pending, :synced ]
	aasm :item, :column => :item_state, :skip_validation_on_save => true do
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
end
