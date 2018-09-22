# frozen_string_literal: true

require "censys"
require "json"
require "slack-notifier"
require "thor"

module CensysWatch
  class CLI < Thor
    desc "search [QUERY]", "execute Censys search by using [QUERY]"
    method_option :type, type: :string, default: "ipv4", enum: ["ipv4", "websites"]
    def search(query)
      validate

      res = case options[:type]
            when "ipv4"
              censys.ipv4.search(query: query)
            when "websites"
              censys.websites.search(query: query)
            end

      results = ["Query: #{query}"]
      res.each_page do |page|
        page.each do |result|
          results << result.to_s
        end
      end
      notifier.ping results.join("\n")
    end

    no_commands do
      def validate
        raise ArgumentError, "Please set your Slack webhook url as WEBHOOK_URL environment variable" unless ENV["WEBHOOK_URL"]
        raise ArgumentError, "Please set your Censys ID as CENSYS_ID environment variable" unless ENV["CENSYS_ID"]
        raise ArgumentError, "Please set your Censys secret key as CENSYS_SECRET environment variable" unless ENV["CENSYS_SECRET"]
      end

      def censys
        Censys::API.new
      end

      def notifier
        Slack::Notifier.new(ENV["WEBHOOK_URL"], channel: ENV["SLACK_CHANNEL"] || "#general")
      end
    end
  end
end
