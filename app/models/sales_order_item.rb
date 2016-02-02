class SalesOrderItem < ActiveRecord::Base
  belongs_to :sales_order
  belongs_to :item
end
