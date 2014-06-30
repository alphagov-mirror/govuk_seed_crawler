module GovukSeedCrawler
  class Seeder
    def self.seed(options = {})
      urls = GetUrls.new(options[:site_root]).urls
      topic_exchange = TopicExchange.new(options)

      PublishUrls::publish(topic_exchange, options[:amqp_topic], urls)

      topic_exchange.close
    end
  end
end
