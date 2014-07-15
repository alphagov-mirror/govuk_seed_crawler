require 'spec_helper'
require 'rabbitmq/http/client'

describe GovukSeedCrawler do
  let(:options) {{
      :amqp_exchange => "govuk_seed_crawler_integration",
      :amqp_topic => "#",
      :site_root => "https://www.gov.uk/",
  }}
  let(:amqp_vhost) { "/" }
  let(:rabbitmq_mgmt_client) { RabbitMQ::HTTP::Client.new("http://guest:guest@127.0.0.1:15672") }
  let(:probable_min_number_of_urls) { 1000 }

  subject { GovukSeedCrawler::Seeder::seed(options) }

  before(:each) do
    rabbitmq_mgmt_client.declare_exchange(amqp_vhost, options[:amqp_exchange], { :type => "topic" })
  end

  after(:each) do
    rabbitmq_mgmt_client.delete_exchange(amqp_vhost, options[:amqp_exchange])
  end

  it "publishes URLs it finds to an AMQP topic exchange" do
    subject

    sleep(1) # give the management API time to recognise the messages we've just published
    exchange_info = rabbitmq_mgmt_client.exchange_info(amqp_vhost, options[:amqp_exchange])
    number_of_messages_on_exchange = exchange_info["message_stats"]["publish_in"]
    expect(number_of_messages_on_exchange).to be > probable_min_number_of_urls
  end
end
