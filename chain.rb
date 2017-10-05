require_relative './block'

class Chain
  attr_reader :blocks

  def initialize
    @blocks = [Block::GENESIS]
  end

  def add_block(block)
    blocks << block if block.valid_after?(blocks.last)

    unless valid_chain?
      @blocks = @blocks[0..-2]
      puts "Refuted block: #{Oj.dump(block, indent: 2)}"
      return false
    end

    puts "New block inserted: #{Oj.dump(block, indent: 2)}"
    true
  end

  def create_and_add_block(data)
    add_block(Block.new(
      index: blocks.last.index + 1,
      linked_hash: blocks.last.hash,
      data: data
    ).make_proof)
  end

  def replace_with(new_blocks)
    return unless valid_chain?(new_blocks) && new_blocks.length > blocks.length
    @blocks = new_blocks
    puts "Block being replaced"
  end

  def valid_chain?(blocks=@blocks)
    blocks.each.with_index(0) do |block, idx|
      break true if idx.zero? ?
        (Oj.dump(block) == Oj.dump(Block::GENESIS)) :
        (block.valid_after?(blocks[idx-1]))
    end # checking each block
  end # valid_chain?
end # Chain
