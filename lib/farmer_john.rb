libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'farmer_john/dm_extension'
require 'farmer_john/planter'
require 'farmer_john/farmer'

# Helper Methods

module FarmerJohn
  def dataset(name = nil, &block)
    Farmer.register_dataset(name, block)
  end
end

include FarmerJohn

# The seed method should create the seed and add it to the current dataset (or
# the default dataset).
