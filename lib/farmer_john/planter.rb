module FarmerJohn
  class Planter
    def initialize(model_name, constraints = nil)
      @model_name = model_name
      @constraints = constraints.nil? ? [] : constraints.to_a
      
      validate_constraints
    end
    
    def plant(data)
      records = []
      
      if data.is_a?(Hash)
        data = [data]
      end
      
      data.each do |hash|
        record = find_or_create_record(hash)
        records.delete(record)
        hash.each_pair do |key, value|
          next unless valid_key?(key)
          
          if value.is_a?(Array)
            value = value.last
          end
          
          record.send("#{key}=", value)
        end
        record.save || raise(ArgumentError, "Validation failed: #{record.errors.inspect}")
        
        records.push(record)
      end
            
      return records
    end
    
    private
    
    def valid_key?(key)
      valid = false
      
      valid = @model_name.complete_properties.include?(key.to_s)
      
      return valid
    end
    
    def find_or_create_record(data)
      return @model_name.new if @constraints.empty?
      
      constraint_data = {}
      @constraints.each do |c|
        constraint_data[c] = data[c]
      end
      
      return @model_name.first(constraint_data) || @model_name.new
    end
    
    def validate_constraints
      unknown_columns = @constraints.map(&:to_s) - @model_name.defined_properties
      unless unknown_columns.empty?
        raise(ArgumentError, "The following constraints don't map to properties in the model: #{unknown_columns}")
      end
    end
  end
end