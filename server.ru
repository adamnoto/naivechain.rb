['digest', 'hanami/router', 'oj', 'restclient', './chain'].each { |lib| require lib }

chain     = Chain.new
peers     = []

REQUEST_ALL_BLOCKS = 'chain/blocks?'.freeze
LAST_BLOCK         = 'chain/last_block'.freeze

app = Hanami::Router.new do
  json_header    = {'Content-Type' => 'application/json'}
  response_with  = -> (data) { [200, json_header, [data]] }
  mine           = -> {}

  get '/peers', to: -> (env) { response_with.(Oj.dump(peers)) }
  get '/chain', to: -> (env) { response_with.(Oj.dump(chain)) }
  get '/chain/blocks', to: -> (env) { response_with.(Oj.dump(chain.blocks)) }

  broadcast = -> (request, peers_arg = peers) do
    puts "Peers: #{peers_arg}"
    peers_arg.each do |peer|
      puts "Broadcasting #{request} to: #{peer}"
      case request
      when REQUEST_ALL_BLOCKS then mine.(RestClient.get("#{peer}/chain/blocks"))
      when LAST_BLOCK
        RestClient.post("#{peer}/chain/mine", Oj.dump([chain.blocks.last]))
      end
    end
  end # broadcasts

  get '/peers/register/:port', to: -> (env) do
    port = env['router.params'][:port]
    addr = "http://localhost:#{port}"
    peers.delete_if { |addr| addr.include?(":#{port}") }
    if port =~ /^\d+$/ && env['SERVER_PORT'] != port
      peers << addr
      puts "Mutually registering peer, sending register request to #{addr}"
      if (env['QUERY_STRING'] =~ /nofollow/).nil?
        RestClient.get "#{addr}/peers/register/#{env['SERVER_PORT']}?nofollow"
      end
      broadcast.(LAST_BLOCK, [addr])
    end
    [200, json_header, [Oj.dump({'succeed' => true})]]
  end # register/port

  post '/chain/add', to: -> (env) do
    chain.create_and_add_block(Rack::Request.new(env).body.read)
    broadcast.(LAST_BLOCK)
    response_with.(Oj.dump(chain.blocks.last))
  end # chain/add for client

  mine = -> (received_blocks) do
    puts "Receiving: #{received_blocks}"
    received_blocks = Oj.load(received_blocks)
    received_blocks.sort! { |x, y| x.index <=> y.index }
    if received_blocks.last.index > chain.blocks.last.index
      if received_blocks.last.linked_hash == chain.blocks.last.hash
        if received_blocks.last.valid_proof?
          puts "Exactly one block ahead"
          chain.add_block(received_blocks.last)
          broadcast.(LAST_BLOCK)
        else
          puts "Ignored false blocks having invalid proof"
        end
      elsif received_blocks.length == 1
        puts "Ask for whole block instead"
        broadcast.(REQUEST_ALL_BLOCKS)
      elsif received_blocks.length > 1
        puts "Replacing singularity"
        chain.replace_with(received_blocks)
        broadcast.(LAST_BLOCK)
      end
    else
      puts "No action needed. Ignoring."
    end # conditional
  end

  post '/chain/mine', to: -> (env) do
    mine.(Rack::Request.new(env).body.read)
    [200, {}, ['200/OK']]
  end # chain/mine
end # Router
run app
