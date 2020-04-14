# frozen_string_literal: true

# MAKE DEEP COPY
# a method for returning deep copies of arrays, hashes,
# structs, and with exceptional usage for Sets as described below
##  TO DO:  structs, possibly fix/revise or omit set functionality

require 'set'

METHOD_NAMES = { Array => :arr_branch,
                 Hash => :hsh_branch,
                 Set => :set_branch }.freeze
COLLECTION_TYPES = METHOD_NAMES.keys

def collection_type(elem)
  COLLECTION_TYPES.each { |cls| return cls if elem.class == cls }
  nil
end

def arr_branch(elem)
  elem.map do |e|
    collection_helper(e)
  end
end

def hash_branch(elem)
  elem.map do |k, v|
    [collection_helper(k), collection_helper(v)]
  end.to_h
end

def sets_branch(elem)
  # sets are a special case.  by definition sets are not intended to be accessed by element
  # however there may be use cases for accessing set elements via to_a
  # to_a and sets are also a special
  # because of the way set#to_a hash elements by default which results in unexpected results
  # in object_id when comparing multiple sets.to_a, to_a is redefined here
  # for the singleton class of any set passed to the collection_deep_copy method
  
  class << elem
    def to_a
      map { |e| collection_helper(e) }
    end
  end

  elem.map do |e|
    collection_helper(e)
  end.to_set
end

def collection_helper(elem)
  c_type = collection_type(elem)
  return elem.dup unless c_type

  method(METHOD_NAMES[c_type]).call(elem)
end

def collection_deep_copy(cll)
  unless collection_type(cll)
    raise TypeError,
          'Error: Argument passed to deep_copy method must be a collection'
  end
  collection_helper(cll)
end