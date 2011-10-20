require 'dm-core'

module DataMapper
  module Model
    def define(name = :default, values)
      @defaults = {} if @defaults.nil?
      @defaults[name] = values
    end
    
    def constrain(*fields)
      return FarmerJohn::Planter.new(self, @defaults, fields)
    end
    
    def plant(*args)
      return FarmerJohn::Planter.new(self, @defaults).plant(*args)
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