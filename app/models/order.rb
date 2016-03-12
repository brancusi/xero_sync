class Order < ActiveRecord::Base
  include AASM

  after_create :generate_invoice_number

  XERO_STATE_MAPPING = {
    voided: 'VOIDED'
  }

  enum order_state: [ :pending, :fulfilled, :voided ]
  aasm :order, :column => :order_state, :skip_validation_on_save => true do
    state :pending, :initial => true
    state :fulfilled
    state :voided

    event :fulfill do
      transitions :from => :pending, :to => :fulfilled
    end

    event :void do
      transitions :from => [:pending, :fulfilled], :to => :voided
    end
  end

  enum notifications_state: [ :unprocessed, :processed ]
  aasm :notifications, :column => :notifications_state, :skip_validation_on_save => true do
    state :unprocessed, :initial => true
    state :processed

    event :process do
      transitions :from => :unprocessed, :to => :processed
    end
  end

  def xero_state
    XERO_STATE_MAPPING[self.aasm.current_state]
  end

  belongs_to :location
  has_many :order_items, -> { joins(:item).order('position') }, :dependent => :destroy, autosave: true

  private
    def generate_invoice_number
      date = Date.today.strftime('%y%m%d')
      self.order_number = "#{date}-#{id}"
      save
    end
end
