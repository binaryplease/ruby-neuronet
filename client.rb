# encoding: utf-8
require './lib/nn_unit'
# Create new net with 3 layers and 10 units each
net = NNNet.new(10,3)


# Create two connections
#net.connect(0,0,1,0,1)
#net.connect(1,0,2,9,1)

# Create all connections with 0 weight
#net.connect_all(0)

# Set the weight of some connections
#net.set_connection_weight(0,0,0,1)
#net.set_connection_weight(0,1,0,1)
#net.set_connection_weight(1,0,0,1)

# Increase the weight of a single connection
#net.add_connection_weight(0,0,0,1)



input = [1,1,1,1,1,1,1,1,1,1]
expected =[0,0,0,0,0,0,0,0,0,0] 
net.train0(-1,1,140000, input, expected)

#err = net.calculate_error_vec(output, expected)
#puts "output was #{output} "
#puts "expected was #{expected} "

#puts "error vector is #{err}"


# Run !
#output = net.run


