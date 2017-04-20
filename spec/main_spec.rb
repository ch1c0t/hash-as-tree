require 'helper'

require 'hash/as/tree'
using Hash::As::Tree

describe do
  it do
    hash =  {
      path: '/path',
      query: {
        'first' => 'one',
        'second' => 'two'
      }
    }

    rewritten = hash.rewrite { |node| node }

    assert { hash == rewritten }
  end

  it do
    hash =  {
      path: '/path',
      query: {
        'first' => 'one',
        'second' => 'two'
      }
    }

    rewritten = hash.rewrite do |node|
      if node.key == 'first'
        node.with value: (node.value * 2)
      else
        node
      end
    end

    assert { rewritten[:query]['first'] == 'oneone' }
  end

  it do
    hash = {
      path: '/path'
    }

    hash.traverse do |node|
      if node.key == :path
        key, value = *node
        assert { key == :path }
        assert { value == '/path' }
      end
    end
  end

  it do
    hash =  {
      path: '/path',
      query: {
        'first' => 'one',
        'second' => 'two'
      }
    }

    rewritten = hash.rewrite do |node|
      node.with key: node.key.to_s
    end

    assert { rewritten['query']['first'] == 'one' }
  end

  it 'does not modify initial hash' do
    hash =  {
      path: '/path',
      query: {
        'first' => 'one',
        'second' => 'two'
      }
    }

    hash.rewrite do |node|
      node.with key: node.key.to_s
    end

    assert { hash['query'] == nil }
    assert { hash[:query]['first'] == 'one' }
  end
end
