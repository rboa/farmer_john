module FarmerJohn
  class Seed
    def initialize(model_class, fields, constraints = nil)
      @model = model_class
      @fields = fields
      @constraints = constraints || []
      
      validate_constraints
    end
    
    def model
      return @model
    end
    
    def constraints
      return @constraints
    end
    
    def values
      return @fields
    end
    
    private
    
    def validate_constraints
      unknown_columns = @constraints.map(&:to_s) - @model.defined_properties
      unless unknown_columns.empty?
        raise(ArgumentError, "The following constraints don't map to properties in the model: #{unknown_columns}")
      end
    end
  end
end