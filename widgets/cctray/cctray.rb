require 'time-ago-in-words'

module Sonia
  module Widgets
    class Cctray < Sonia::Widget
      def initialize(config)
        super(config)
        EventMachine::add_periodic_timer(config[:poll_time]) { fetch_data }
      end

      def initial_push
        fetch_data
      end

      private
      def fetch_data
        log_info "Polling `#{service_url}'"
        http = EventMachine::HttpRequest.new(service_url).get
        http.errback { log_fatal_error(http) }
        http.callback {
          handle_fetch_data_response(http)
        }
      end

      def handle_fetch_data_response(http)
        if http.response_header.status == 200
          parse_response(http.response)
        else
          log_unsuccessful_response_body(http.response)
        end
      end

      def parse_response(response)
        items = Nokogiri::XML.parse(response).xpath("//Projects/Project").map{|t| mapElement(t)}
        log_info("RSS items: #{items}")
        push :items => items[0...config[:nitems]]
      rescue => e
        log_backtrace(e)
      end

      def mapElement(element)
        {
            :build_status => element['lastBuildStatus'],
            :name => element['name'],
            :time => Time.strptime(element['lastBuildTime'], "%Y-%m-%dT%H:%M:%S").ago_in_words,
            :url => element['webUrl']
        }
      end

      def service_url
        config[:url]
      end
    end
  end
end
