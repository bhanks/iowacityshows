class WorkerJob < Struct.new(:state)
	def perform
		if(state == 'on')
			Kernel.system "heroku workers 1"
		elsif(state == 'off')
			Kernel.system "heroku workers 0"
		end
	end
end