require 'dm-core'

module DataMapper
  module Model
    def plant(seeds)
      if seeds.is_a?(Hash)
        return FarmerJohn::Planter.plant(self, seeds)
      end
      
      arr = []
      seeds.to_a.each do |seed|
        arr.push(FarmerJohn::Planter.plant(self, seed))
      end
      return arr
    end
    
    alias :seed :plant
    
    def accepted_properties
      repository = self.repository_name
      list = properties(repository) + relationships(repository)
      return list.map {|i| i.field}
    end
  end
end