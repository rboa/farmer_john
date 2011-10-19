require 'dm-core'

module DataMapper
  module Model
    def constrain(*fields)
      return FarmerJohn::Planter.new(self, fields)
    end
    
    def plant(seeds)
      return FarmerJohn::Planter.new(self).plant(seeds)
    end
    
    alias :seed :plant
    
    def defined_properties
      return properties(self.repository_name).map {|i| i.field}
    end
    
    def defined_relationships
      return relationships(self.repository_name).map {|i| i.field}
    end
    
    def complete_properties
      repository = self.repository_name
      list = properties(repository) + relationships(repository)
      return list.map {|i| i.field}
    end
  end
end