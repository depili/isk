# ISK - A web controllable slideshow system
#
# Author::    Vesa-Pekka Palmu
# Copyright:: Copyright (c) 2012-2013 Vesa-Pekka Palmu
# License::   Licensed under GPL v3, see LICENSE.md


module EventsHelper
	
	# Buttons
	def event_edit_button(event)
		link_to edit_link_text, edit_event_path(event), class: 'button'
	end
	
	def event_details_button(event)
		link_to details_link_text, event_path(event), class: 'button'
	end
	
	def event_delete_button(event)
		options = {
			method: :delete, 
			class: 'button warning',
			data: {confirm: 'Are you sure you want to delete this event?'}
			}
		link_to delete_link_text, event_path(event), options
	end
	
	def event_list_button
		link_to (icon('list') + ' List events'), events_path, class: 'button'
	end
	
	def event_new_button
		link_to (icon('plus') + ' New event'), new_event_path, class: 'button'
	end
	
	# Select box for choosing the slide resolution for the event.
	def event_slide_resolution_select(event)
		resolutions = Event::SupportedResolutions
		options = resolutions.collect.with_index do |r, i|
			["#{r.first} x #{r.last}", i]
		end
		
		selected = resolutions.index event.picture_sizes[:full]
		
		return select_tag(:resolution, options_for_select(options, selected) )
	end
	
	# Link to regenerate all slide images for a event
	def event_generate_images_link(event)
		options = {
			method: :post, 
			data: {confirm: 'This operation will take a long time, are you sure?'},
			title: 'Regenerate all slide images, this will take a long time.'
		}
		link_to 'Regenerate images', generate_images_event_path(@event), options
	end
end
