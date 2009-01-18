require File.dirname(__FILE__) + '/test_harness'

module BasicPostHelper
  class Post < ActiveRecord::Base
    profanity_filter! :title, :body
  end
end

module DictionaryPostHelper
  class Post < ActiveRecord::Base
    profanity_filter! :title, :body, :method => 'dictionary'
  end
end

class BasicProfanityFilterTest < Test::Unit::TestCase
  include BasicPostHelper

  def profane_post(opts={})
    Post.new({:title => 'A Fucking Title', :body => "This is some shitty post by a fucking user"}.merge(opts))
  end
  
  def test_it_should_filter_specified_fields
    p = profane_post
    p.save
    assert_equal 'A @#$% Title', p.title
    assert_equal 'This is some @#$% post by a @#$% user', p.body
  end
  
  def test_it_should_handle_nil_fields_bug_9
    p = Post.new({:title => nil, :body => nil})
    p.save
    assert_equal nil, p.title
    assert_equal nil, p.body
  end
  
  def test_it_should_handle_blank_fields_bug_9
    p = Post.new({:title => "", :body => ""})
    p.save
    assert_equal "", p.title
    assert_equal "", p.body
  end
end

class DictionaryProfanityFilterTest < Test::Unit::TestCase
  include DictionaryPostHelper
  
  def profane_post(opts={})
    Post.new({:title => 'A Fucking Title', :body => "This is some shitty post by a fucking user"}.merge(opts))
  end
  
  def test_it_should_filter_specified_fields
    p = profane_post
    p.save
    assert_equal 'A f*ck*ng Title', p.title
    assert_equal 'This is some sh*tty post by a f*ck*ng user', p.body
  end
  
  def test_it_should_handle_nil_fields_bug_9
    p = Post.new({:title => nil, :body => nil})
    p.save
    assert_equal nil, p.title
    assert_equal nil, p.body
  end
  
  def test_it_should_handle_blank_fields_bug_9
    p = Post.new({:title => "", :body => ""})
    p.save
    assert_equal "", p.title
    assert_equal "", p.body
  end
end