require 'dm-core'

module DataMapper
  module Model
    def define(name = :default, values)
      FarmerJohn::Farmer.assign_defaults(self, name, values)
    end
    
    def constrain(*fields)
      @constraints = fields
      return self
    end
    
    def plant(*args)
      FarmerJohn::Farmer.create_seeds(self, @constraints, *args)
      @constraints = nil
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