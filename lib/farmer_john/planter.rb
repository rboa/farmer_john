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
      
      found_object = nil
      constraint_data = {}
      multi_constraints = {}
      @constraints.each do |c|
        if data[c].is_a?(Array)
          multi_constraints[c] = data[c]
        else
          constraint_data[c] = data[c]
        end
      end
      objects = @model_name.all(constraint_data)
      return @model_name.new unless objects
      
      unless multi_constraints.keys.empty?
        peg = {}
        multi_constraints.each do |key, value|
          peg[value] = [value.length - 1, key]
        end

        nperms= 1
        multi_constraints.each_value { |a| nperms  *=  a.length }
      
        nperms.times do |p|
          permutation = {}
          multi_constraints.each_value do |a|
            permutation.store(peg[a][1], a[peg[a][0]])
          end
          
          found_object = objects.first(permutation)
          return found_object unless found_object.nil?

          multi_constraints.each_value do |a|
            peg[a][0] -= 1
            break  if peg[a][0] >= 0
            peg[a][0] = a.length - 1
          end
        end
      else
        found_object = objects.first
      end
      
      return found_object || @model_name.new
    end
    
    def validate_constraints
      unknown_columns = @constraints.map(&:to_s) - @model_name.defined_properties
      unless unknown_columns.empty?
        raise(ArgumentError, "The following constraints don't map to properties in the model: #{unknown_columns}")
      end
    end
  end
end