# Naivechain.rb

Naivechain is a Ruby implementation of Blockchain in 167 lines.

Blockchain is a distributed peer-to-peer, non-functional<sup>$</sup> implementation that
can be used in a lot of cases where intermediaries exist.
Blockchain attempts to disintermediate the world using publicly transparent
chains of data spread over nodes.
distributed over nodes, that when added need to have some sort of proof of work
so that it would be harder to deceive and manipulate the network for illegitimate benefits.

This implementation takes inspiration from
[Naivechain](https://github.com/lhartikk/naivechain) excepts:

1. It used HTTP for all communication
2. It has proof of work mechanism albeit very simple
3. It is written in an object-oriented fashion: `Block` and `Chain` class.

<sup>$</sup>: Non-functional requirement: a requirement specifying the how part of
of a system, eg: how the system will work that is: it will work by involving a
Blockchain, Merle tree, and so on. On the other hand, making borderless transaction
is a functional requirement.

## Running

Start the server:

```ruby
rackup ./server.ru -p 9292
```

Start the client tool:

```
ruby client.rb
Blockchain client
Specify the port: 9292
9292> hi there
```

You may spawn as many server and client instances as you please.

## Endpoints

| Endpoint | Purpose
| -------- | ---------
| /peers | Listing all peers
| /chain | Showing the chain, including the blocks
| /chain/blocks | Showing the blocks in the chain 
| /peers/register/:port | Adding a peer in this node, and vice-versa
| /chain/add | Convenient endpoint to add a new block with text data
| /chain/mine | Endpoint for peer-to-peer communications
