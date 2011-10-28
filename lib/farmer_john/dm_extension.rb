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
      results = FarmerJohn::Farmer.create_seeds(self, @constraints, *args)
      @constraints = nil
      return results
    end
    
    alias :seed :plant
    
    def defined_properties
      return properties(self.repository_name).map {|i| i.field}
    end
    
    def defined_relationships
      return relationships(self.repository_name).map {|i| i.field}
    end
    
    def child_model_index
      return Hash[relationships(self.repository_name).map {|i| [i.field.to_sym, i.child_model]}]
    end
  end
end