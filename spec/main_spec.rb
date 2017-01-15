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
end
