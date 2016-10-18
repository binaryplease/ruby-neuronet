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
				@children.each do |c|
						c.unit.trigger(@activity * c.weight)
				end
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
				puts "outuput of #{@id}: #{@activity}"
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

		def propagate
				@units.each do |unit|
						unit.propagate
				end
		end
end

class NNNet

		attr_reader :net, :size
		attr_writer :net

		include NNTrainer

		def input(input_vec)
				if input_vec.length !=@size
						puts "input was #{input_vec.length} size is #{size}"
						raise("input doesnt match size")
				end

				net[0].units.each_with_index do |unit, index|
						puts "setting #{input_vec[index]}"
						unit.activity = input_vec[index]
				end
		end

		def run
				@net.each_with_index do |layer, i|
						puts "running layer: #{i}"
						layer.propagate
				end
		end


		def initialize (size, layers)
				@size = size
				if layers < 2
						raise "to small layers"
				end

				if size < 2
						raise "to small size"
				end


				layer_first = NNLayer.new(size, "input", 0)
				layer_last = NNLayer.new(size, "output", layers)

				@net = []
				@net << layer_first

				(layers - 2).times do |n|
				layer_middle  = NNLayer.new(size, "hidden", n)
						@net << layer_middle
				end

				@net << layer_last

		end

		def connect_all(weight)
				@net.each_with_index do |l, n|
						return if n >= (@net.length - 1)
						l.units.each_with_index do |u, m|
								net[n+1].units.each do |u2|
										#puts "setting child for #{n}.#{m}"
										u.children << NNConnection.new( u2 , weight)
								end
						end
				end
		end

		def connect(layer_from, node_from, layer_desc, node_desc, weight)
				@net[layer_from].units[node_from].add_connection(@net[layer_desc].units[node_desc],weight)

		end

		def set_connection_weight(layer_src, node_src, node_dest, weight)
				@net[layer_src].units[node_src].children.select{ |c| c.unit.id = node_dest}.first.weight = weight
		end

		def add_connection_weight(layer_src, node_src, node_dest, weight)
				@net[layer_src].units[node_src].children.select{ |c| c.unit.id = node_dest}.first.weight += weight
		end

end


