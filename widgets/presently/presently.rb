require 'twitter/json_stream'

module Sonia
  module Widgets
    class Presently < Sonia::Widget
      FRIENDS_TIMELINE_URL  = "http://%s.presently.com/api/twitter/statuses/friends_timeline.json?count=%s"

      def initialize(config)
        super(config)
      end

      def initial_push
        log_info "Polling `#{friends_timeline_url}'"
        http = EventMachine::HttpRequest.new(friends_timeline_url).get(headers)
        http.errback { log_fatal_error(http) }
        http.callback {
          handle_initial_push(http)
        }
      end

      private
      def handle_initial_push(http)
        if http.response_header.status == 200
          parse_json(http.response)[0..config.nitems].reverse.each do |status|
            push format_status(status)
          end
        else
          log_unsuccessful_response_body(http.response)
        end
      rescue => e
        log_backtrace(e)
      end


      def headers
        { :head => { 'Authorization' => [config.username, config.password] } }
      end

      def friends_timeline_url
        FRIENDS_TIMELINE_URL % [config.account, config.nitems]
      end



      def format_status(status)
        {
          :text              => status['text'],
          :user              => status['user']['screen_name'],
          :profile_image_url => status['user']['profile_image_url']
        }
      end
    end
  end
end
