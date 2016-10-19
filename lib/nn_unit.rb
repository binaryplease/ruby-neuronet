# encoding: utf-8
require './lib/nn_trainer'

class NNConnection
		attr_accessor :unit, :weight
		def initialize(u,w)
				@weight = w
				@unit = u
		end
end

class NNUnit
		attr_accessor :activity, :children, :id

		def initialize(id)
				@id = id
				@children = []
				@activity = 0
		end

		def disconnect
				@children = []
		end


		def propagate
				out = []
				@children.each do |c|
						c.unit.trigger(@activity * c.weight)
						out << @acitivity
				end
				return out
		end

		def trigger(input)
				@activity += input
		end

		def add_connection(unit, weight)
				@children << NNConnection.new(unit,weight)
		end
end

class NNHiddenUnit < NNUnit
		@type = :hidden
end

class NNInputUnit < NNUnit
		@type = :input
end

class NNOutputUnit < NNUnit
		@type = :output

		def propagate
				#puts "outuput of #{@id}: #{@activity}"
				return @activity
		end
end

class NNLayer

		attr_accessor :units
		attr_reader :id

		def initialize(size, type, id)
				@id = id
				@units = []
				case type
				when "input"
						size.times  do |n|
								@units << NNInputUnit.new(n)
						end
						return

				when "output"
						size.times	do |n|
								@units << NNOutputUnit.new(n)
						end
						return

				when "hidden"
						size.times	do |n|
								@units << NNHiddenUnit.new(n)
						end
						return
				end

		end

		def size
				return @units.length

		end

		def propagate
				output = []
				@units.each do |unit|
						output << unit.propagate
				end
				return output
		end
end

class NNNet

		attr_reader :net, :size
		attr_writer :net

		include NNTrainer

		def run(input_vec)
				input(input_vec)
				output = []
				@layers.each_with_index do |layer, i|
						#puts "running layer: #{i}"
						output = layer.propagate
				end
				return output
		end


		def initialize (size, layers)

				@init_size = size
				@init_layers = layers
				if layers < 2
						raise "to small layers"
				end

				if size < 2
						raise "to small size"
				end


				layer_first = NNLayer.new(size, "input", 0)
				layer_last = NNLayer.new(size, "output", layers)

				@layers = []
				@layers << layer_first

				(layers - 2).times do |n|
						layer_middle  = NNLayer.new(size, "hidden", n)
						@layers << layer_middle
				end

				@layers << layer_last

		end


		# How many layers the net has
		def depth
				return @layers.length
		end

		# How many nodes per layer
		def size(layer =0)
				return @layers[layer].size
		end

		# Reset the network keeping original input vector
		def reset
				@layers = []
				initialize(@init_size, @init_layers)
		end

		def connect_all(weight)
				@layers.each_with_index do |l, n|
						return if n >= (@layers.length - 1)
						l.units.each_with_index do |u, m|
								@layers[n+1].units.each do |u2|
										#puts "setting child for #{n}.#{m}"
										u.children << NNConnection.new( u2 , weight)
								end
						end
				end
		end


		def connect_all_predefined(weights)

				#if weights.length != @num_connections
				#raise("wrong number of weights (#{weights.length}  for #{@num_connections} connections)")
				#end

				count = 0

				@layers.each_with_index do |l, n| # each layer
						return if n >= (@layers.length - 1)
						l.units.each_with_index do |u, m| #each unit in layer
								u.disconnect
								@layers[n+1].units.each do |u2|
										#puts "setting child for #{n}.#{m}"
										u.children << NNConnection.new( u2 , weights[count])
										count += 1
								end
						end
				end
		end


		#def connect_all_random(min, max)
		#@layers.each_with_index do |l, n|
		#return if n >= (@layers.length - 1)
		#l.units.each_with_index do |u, m|
		#net[n+1].units.each do |u2|
		##puts "setting child for #{n}.#{m}"
		#u.children << NNConnection.new( u2 , range(min, max))
		#count += 1
		#end
		#end
		#end
		#end

		def range (min, max)
				rand * (max-min) + min
		end

		def connect(layer_from, node_from, layer_desc, node_desc, weight)
				@layers[layer_from].units[node_from].add_connection(@layers[layer_desc].units[node_desc],weight)
		end

		def set_connection_weight(layer_src, node_src, node_dest, weight)
				@layers[layer_src].units[node_src].children.select{ |c| c.unit.id = node_dest}.first.weight = weight
		end

		def add_connection_weight(layer_src, node_src, node_dest, weight)
				@layers[layer_src].units[node_src].children.select{ |c| c.unit.id = node_dest}.first.weight += weight
		end
		
		private
		def input(input_vec)
				@init_input_vec = input_vec
				if input_vec.length !=@layers[0].size
						puts "input was #{input_vec.length} size is #{@layers[0].size}"
						raise("input doesnt match size")
				end

				#puts "input: #{input_vec}"
				@layers[0].units.each_with_index do |unit, index|
						unit.activity = input_vec[index]
				end
		end


end


