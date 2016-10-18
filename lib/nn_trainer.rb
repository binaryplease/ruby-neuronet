module NNTrainer



		def	calculate_error_vec(output, expected)
				ret = []
				output.each_with_index do |e,i|
						ret << (output[i].abs - expected[i].abs).abs
				end
				return ret

		end

		def train1
				#Hebb-Regel
		end

		def train2
				#Delta-Regel
		end

		def train3
				#Backpropagation
		end

		def train4
				#Competitive Learning
		end

end
