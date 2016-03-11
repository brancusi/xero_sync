class Order < ActiveRecord::Base
  include AASM

  enum aasm_state: {
    draft: 0,
    processed: 1,
    fulfilled: 2,
    invoiced: 3,
    deleted: 4,
    voided: 5
  }

  aasm :skip_validation_on_save => true do
    state :draft, :initial => true
    state :processed
    state :fulfilled
    state :invoiced
    state :deleted
    state :voided

    event :invoice do
      transitions :from => :fulfilled, :to => :invoiced
    end

    event :void do
      transitions :from => [:draft, :processed], :to => :deleted
      transitions :from => [:fulfilled, :invoiced], :to => :voided
    end
  end

  belongs_to :location
  has_many :order_items, -> { joins(:item).order('position') }, :dependent => :destroy, autosave: true
end
