require 'dm-core'

module DataMapper
  module Model
    def plant(seeds)
      if seeds.is_a?(Hash)
        FarmerJohn::Planter.plant(self, seeds)
        return
      end
      
      seeds.to_a.each do |seed|
        FarmerJohn::Planter.plant(self, seed)
      end
    end
    
    alias :seed :plant
    
    def column_names
      properties.map {|i| i.field}
    end
  end
end