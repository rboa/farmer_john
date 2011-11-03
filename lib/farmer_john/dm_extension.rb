require 'dm-core'

module DataMapper
  module Model
    #TODO: fix for 1.8.7 and test more
    def define(name = :default, values)
      FarmerJohn::Farmer.assign_defaults(self, name, values)
    end
    
    def constrain(*fields)
      @constraints = fields
      return self
    end
    
    def cache(*fields)
      @cache = fields
      return self
    end
    
    def plant(*args)
      results = FarmerJohn::Farmer.create_seeds(self, @constraints, @cache, *args)
      @constraints = nil
      @cache = nil
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
