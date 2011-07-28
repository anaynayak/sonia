require 'ri_cal'

module Sonia
  module Widgets
    class Webcal < Sonia::Widget
      URL = "https://neatco.jira.com/wiki/plugins/calendar/ical/dc.action?pageId=2555906&cid=staypuftCalendar&scid=635FHI9KE09VT5O5RIUMCKK76Z3FLUGF&os_authType=basic"

      def initialize(config)
        super(config)
        EventMachine::add_periodic_timer(60 * 15) { fetch_data }
      end

      def initial_push
        fetch_data
      end

      private
      def fetch_data
        log_info "Polling `#{service_url}'"
        http = EventMachine::HttpRequest.new(service_url).get(headers)
        http.errback { log_fatal_error(http) }
        http.callback {
          handle_fetch_data_response(http)
        }
      end

      def headers
        { :head => { 'Authorization' => [config.username, config.password] } }
      end
      
      def handle_fetch_data_response(http)
        if http.response_header.status == 200
          parse_response(http.response)
        else
          log_unsuccessful_response_body(http.response)
        end
      end

      def parse_response(response)
        cals = RiCal.parse_string response.strip
        now = Time.now
        events = cals.first.events.sort {|a,b| b.dtstart <=> a.dtstart}.reject {|event| now > event.dtend }
        events.each {|event| push formatted_event(event)}
      end  

      def formatted_event(event) 
        {
            :start_date => event.dtstart,
            :end_date => event.dtend,
            :location => event.location,
            :summary => event.summary,
        }
      end

      def service_url
        URL % [config.username, config.password]
      end
    end
  end
end
