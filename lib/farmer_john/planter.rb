module FarmerJohn
  class Planter
    def initialize(model_name, defaults = nil, constraints = nil)
      @model_name = model_name
      @constraints = constraints.nil? ? [] : constraints.to_a
      @defaults = (defaults.nil? || !defaults.is_a?(Hash)) ? {} : defaults
      
      validate_constraints
    end
    
    def plant(*args)
      name = :default
      data = {}
      args.each do |param|
        name = param if param.is_a?(Symbol)
        data = param if param.is_a?(Hash) || param.is_a?(Array)
      end
      
      records = []
      
      if data.is_a?(Hash)
        data = [data]
      end
      
      data.each do |hash|
        values = @defaults[name].is_a?(Hash) ? @defaults[name].merge(hash) : hash
        record = find_or_create_record(values)
        records.delete(record)
        values.each_pair do |key, value|
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
    
    alias :seed :plant
    
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