require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/permalink_fu_hack')

class FauxColumn < Struct.new(:limit)
end

class BaseModel
  def self.columns_hash
    @columns_hash ||= {'permalink' => FauxColumn.new(100)}
  end
  
  include PermalinkFu
  attr_accessor :id
  attr_accessor :title
  attr_accessor :extra
  attr_reader   :permalink
  attr_accessor :foo
  
  class << self
    attr_accessor :validation
  end
  
  def self.generated_methods
    @generated_methods ||= []
  end
  
  def self.primary_key
    :id
  end
  
  def self.logger
    nil
  end
  
  # ripped from AR
  def self.evaluate_attribute_method(attr_name, method_definition, method_name=attr_name)
    
    unless method_name.to_s == primary_key.to_s
      generated_methods << method_name
    end
    
    begin
      class_eval(method_definition, __FILE__, __LINE__)
    rescue SyntaxError => err
      generated_methods.delete(attr_name)
      if logger
        logger.warn "Exception occurred during reader method compilation."
        logger.warn "Maybe #{attr_name} is not a valid Ruby identifier?"
        logger.warn "#{err.message}"
      end
    end
  end
  
  def self.exists?(*args)
    false
  end
  
  def self.before_validation(method)
    self.validation = method
  end
  
  def validate
    send self.class.validation
    permalink
  end
  
  def new_record?
    @id.nil?
  end
  
  def write_attribute(key, value)
    instance_variable_set "@#{key}", value
  end
end

class DoNotFilterStopWordModel < BaseModel
  has_permalink :title
end

class FilterStopWordModel < BaseModel
  has_permalink :title, :filter_stop_words => true
end

class UniquePermalinkModel < BaseModel
  def self.exists?(conditions)
    if conditions[1] == 'foo'   || conditions[1] == 'bar' || 
      (conditions[1] == 'bar-2' && conditions[2] != 2)
      true
    else
      false
    end
  end

  has_permalink :title
end

class NonUniquePermalinkModel < BaseModel
  def self.exists?(conditions)
    return true if conditions[1] == 'foo'
  end

  has_permalink :title, :unique => false
end

class PermalinkFuOnSteroidsTest < Test::Unit::TestCase
  @@samples = {
    'The Ultimate Book 1' => 'ultimate-book-1',
    'Ultimate The Book 2' => 'ultimate-book-2',
    'Ultimate Book 3 The' => 'ultimate-book-3',
    "Surely You're kidding Mr. Feynman" => 'surely-kidding-feynman'
  }
  
  def test_should_not_filter_stop_words
    @m = DoNotFilterStopWordModel.new
    @m.title = 'do not filter the stop word'
    @m.validate
    assert_equal 'do-not-filter-the-stop-word', @m.permalink
  end
  
  def test_should_filter_stop_words
    @m = FilterStopWordModel.new
    @m.title = 'do not filter the stop word'
    @m.validate
    assert_equal 'filter-stop-word', @m.permalink
  end
  
  def test_should_truncate_long_permalink
    expected = "streetwise-portland-map-laminated-city-street"
    
    @m = FilterStopWordModel.new
    @m.title = "Streetwise Portland Map - Laminated City Street Map of Portland, Oregon - with integrated Max Light Rail map featuring lines & stations"
    @m.validate
    
    assert_equal expected, @m.permalink
  end
  
  def test_should_filter_stop_words_in_various_positions
    @@samples.each do |source, expected|
      @m = FilterStopWordModel.new
      @m.title = source
      @m.validate
      assert_equal expected, @m.permalink
    end
  end
  
  def test_should_create_unique_permalink
    @m = UniquePermalinkModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink
    
    @m.permalink = 'bar'
    @m.validate
    assert_equal 'bar-3', @m.permalink
  end

  def test_should_create_non_unique_permalink
    @m = NonUniquePermalinkModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo', @m.permalink
  end
end