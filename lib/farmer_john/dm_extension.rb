require 'dm-core'

module DataMapper
  module Model
    def plant(seeds)
      seeds.to_a.each do |seed|
        FarmerJohn::Planter.plant(self, seed)
      end
    end
    
    def column_names
      properties.map {|i| i.field}
    end
  end
end