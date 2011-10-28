module FarmerJohn
  class Planter
    def self.plant_seeds(models)
      models.each do |model, seeds|
        seeds.each do |seed|
          record = find_or_create_record(seed.model, seed.constraints, seed.values)
          
          populate_values_in_record(record, seed)
          
          record.save || raise(ArgumentError, "Validation failed: #{record.errors.inspect}")
        end
      end
    end
    
    private
    
    def self.populate_values_in_record(record, seed)
      seed.values.each do |key, value|
        type = key_type(seed.model, key)
        next if type == :unknown
        
        if type == :assoc
          removable_children = []
          value.flatten.each do |child|
            if child.is_a?(Integer)
              child = FarmerJohn::Farmer.seed_of_type_with_index(seed.model.child_model_index.fetch(key), child)
              removable_children.push(child)
            end
            child_record = find_or_create_child(record, key, child.constraints, child.values)
            populate_values_in_record(child_record, child)
            child_record.save || raise(ArgumentError, "Validation failed: #{child_record.errors.inspect}")
          end
          removable_children.map {|child| FarmerJohn::Farmer.remove_seed(child)}
          next
        end
                
        if value.is_a?(Array)
          value = value.last
        end

        record.send("#{key}=", value)
      end
    end
    
    def self.key_type(model, key)
      type = :unknown
      
      if (model.defined_properties.include?(key.to_s))
        type = :property
      elsif (model.defined_relationships.include?(key.to_s))
        type = :assoc
      end
      
      return type
    end
    
    def self.find_or_create_child(parent, assoc_name, constraints, data)
      group = parent.send(assoc_name)
      return nil unless group
      return group.new if constraints.empty?
      
      found_object = find_object_in_group_by_constraints(group, constraints, data)
      
      return found_object || group.new
    end
    
    def self.find_or_create_record(model, constraints, data)
      return model.new if constraints.empty?
      
      found_object = find_object_in_group_by_constraints(model.all, constraints, data)
      
      return found_object || model.new
    end
    
    def self.find_object_in_group_by_constraints(objects, constraints, data)
      found_object = nil
      constraint_data = {}
      multi_constraints = {}
      constraints.each do |c|
        if data[c].is_a?(Array)
          multi_constraints[c] = data[c]
        else
          constraint_data[c] = data[c]
        end
      end
      objects = objects.all(constraint_data)
      return nil unless objects
      
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
      
      return found_object
    end
=begin    
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
    
    def validate_constraints
      unknown_columns = @constraints.map(&:to_s) - @model_name.defined_properties
      unless unknown_columns.empty?
        raise(ArgumentError, "The following constraints don't map to properties in the model: #{unknown_columns}")
      end
    end
=end
  end
end