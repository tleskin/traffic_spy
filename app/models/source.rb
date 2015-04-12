module TrafficSpy
  class Source < ActiveRecord::Base
    validates :identifier, presence: true
    validates :root_url, presence: true

    has_many :payloads
    has_many :urls, through: :payloads

    def urls
      urls = Payload.pluck(:url_id)
      urls.flat_map {|url| Url.where(id: url).pluck(:name)}
    end

    def ordered_urls
      frequency = urls.reduce(Hash.new(0)) { |h, v| h[v] += 1; h}
      urls.uniq.sort_by {|v| frequency[v] }.reverse
    end

    def url_objects
      payloads = Payload.all
      payloads.map{|payload| payload.url}.uniq
    end

    def browsers
      Payload.pluck(:user_agent_id).map{|user_agent| UserAgent.find(user_agent).browser}
    end

    def platforms
      Payload.pluck(:user_agent_id).map{|user_agent| UserAgent.find(user_agent).platform}
    end

    def resolutions
      Payload.pluck(:resolution_id).map{|resolution| Resolution.find(resolution).dimension}
    end

    def ordered_url_response_times
      response_times = payloads.sort_by { |pl| pl.url.average_response_time }.reverse
      response_times.map { |pl| "#{pl.url.name}: #{pl.url.average_response_time}"}.uniq
    end

    def events
      events = Payload.pluck(:event_name_id)
      events.flat_map{|event| EventName.where(id: event).pluck(:name)}
    end

    def ordered_events
      frequency = events.reduce(Hash.new(0)) { |h, v| h[v] += 1; h}
      events.uniq.sort_by {|v| frequency[v] }.reverse
    end
  end
end
