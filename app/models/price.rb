class Price < ActiveRecord::Base
  belongs_to :event
  validates :amount, :presence => {:message => "Price must not be blank."}
end
