WebsocketRails::EventMap.describe do
	# You can use this file to map incoming events to controller actions.
	# One event can be mapped to any number of controller actions. The
	# actions will be executed in the order they were subscribed.
	#
	# Uncomment and edit the next line to handle the client connected event:


	#subscribe :client_connected, :to => Sockets::, :with_method => :method_name


	#
	# Here is an example of mapping namespaced events:
	#		namespace :product do
	#			subscribe :new, :to => ProductController, :with_method => :new_product
	#		end
	# The above will handle an event triggered on the client like `product.new`.

	# Events for creating various svg previews for slide editors
	namespace :svg do
		# Create a new svg from suplied data using the SimpeSlide.create_svg method
		# data = {
		#		simple: {
		#			heading: 'Slide heading',
		#			text: 'Slide contents...',
		#			color: Red,		# hilight color
		#			text_size: 72,
		#			text_align: 'left' # left, right or centered
		#		}
		# }
		subscribe :simple,				to: SvgController, with_method: :simple
	end

	
	# Events for communication between the ISK server and iskdpy displays
	namespace :iskdpy do
		# Display initializes itself calling this and receives its initial state
		# data = {:display_name: string}
		# returns success, data = {displays serialization}
		subscribe :hello,					to: IskdpyController, with_method: :hello
		
		# The display reports what slide it's currently showing
		# data = {display_id: int, group_id: int, slide_id: int} -> normal state
		# OR
		# data = {display_id: int, override_queue_id: int} -> showing a override slide
		# sends: to display_<id> channel: current_slide message, data={group_id: int, slide_id: int}
		subscribe :current_slide,					to: IskdpyController, with_method: :current_slide
		
		# The remote control gui sends a message to the display telling it to go to a slide
		# data = {display_id: int, +javascript client payload}
		# sends: to display_<id> channel: goto_slide message with same data hash
		subscribe :goto_slide,						to: IskdpyController, with_method: :goto_slide
		
		# Request the resending of the display data
		# Used by the remote control interface to initialize itself
		# data = {display_id: int}
		# returns success, data = {displays serialization}
		subscribe :display_data,					to: IskdpyController, with_method: :display_data
		
	end


end
