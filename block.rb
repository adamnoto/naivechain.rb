class Block
  attr_accessor :index, :data, :time, :hash, :linked_hash, :proof

  def initialize(options = {})
    @time = Time.now.to_i
    @proof = ''
    options.each { |k, v| send("#{k}=", v) }
  end

  def data=(data)
    @data = data
    fail "Cannot nil" if body.index(nil)
    @hash = Digest::MD5.hexdigest(body.join)
  end

  def valid_after?(previous_block)
    (previous_block.hash == linked_hash) &&
      (hash == Digest::MD5.hexdigest(body.join)) &&
      valid_proof?
  end

  def body
    [index, time, data, linked_hash]
  end

  def valid_proof?
    Digest::MD5.hexdigest((body + [proof]).join).start_with?('abc')
  end

  def make_proof
    hash = Digest::MD5.hexdigest(body.join)
    letters = ('a'..'z').to_a
    @proof << letters.sample while !valid_proof?
    self
  end

  GENESIS = Block.new(index: 0, linked_hash: 0, time: 0, data: "\0", proof: "tvqhjhoreobtltjhyvckkigazxbgcnnzborkkcsfqmipqnwvvnkmasglhbhlubaifbyurcccmhdqejldonyzcbjhzdexygsdgijdqbpyqvrjisslzhvzkoljilyruolpxhzszyjdfbaivdkppqobesypuoylqysjxcueolbdiaisfvjwcsnkhnpkltozzfmwanqxweuizvntxrgegljj")
end # Block
