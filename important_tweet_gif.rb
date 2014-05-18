#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require
Dotenv.load '.env'

def client
  @client ||= Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['CONSUMER_KEY']
    config.consumer_secret = ENV['CONSUMER_SECRET']
    config.access_token = ENV['ACCESS_TOKEN']
    config.access_token_secret = ENV['ACCESS_SECRET']
  end
end

def main
  tweet = ARGV.shift
  raise 'tweet required' unless tweet
  builder = ExtremelyImportantTweetImageBuilder.new(tweet)
  builder.build

  client.update("SUPER IMPORTANT TWEET #{builder.url}")
end

class ExtremelyImportantTweetImageBuilder
  BASE_PATH = "/Users/#{ENV['MAC_USER']}/Dropbox/Public/important_tweet/"
  BASE_URL = "http://dl.dropboxusercontent.com/u/#{ENV['DROPBOX_USER_ID']}/important_tweet/"
  FONT_PATH = '/Library/Fonts/ヒラギノ角ゴ StdN W8.otf'

  def initialize(tweet)
    @tweet = tweet
  end

  def build
    images = ::Magick::ImageList.new
    images.delay = 1
    images.iterations = 0

    10.times do
      images << image
    end

    images.
      optimize_layers(Magick::OptimizeLayer).
      write(path)

    wait_for_upload
  end

  def url
    @url ||= BASE_URL + file_name
  end

  private

  def wait_for_upload
    until(`curl -I -X GET '#{url}'`.match(/200 OK/)) do
      sleep 1
    end
  end

  def image
    image = Magick::Image.new(500, 300) do
      color = '#%02x%02x%02x' % [rand * 0x33, rand * 0x33, rand * 0x33]
      self.background_color = color
    end
    draw = Magick::Draw.new
    tweet = @tweet

    draw.annotate(image, 0, 0, 0, 0, @tweet) do
      self.font = FONT_PATH
      self.fill = '#FFFFFF'
      self.gravity = Magick::CenterGravity
      self.stroke = 'none'
      self.pointsize = 300.to_f / tweet.size
      self.text_antialias = true
      self.kerning = 1
    end

    image
  end

  def path
    @path ||= BASE_PATH + file_name
  end

  def file_name
    @file_name ||= "#{SecureRandom.uuid}.gif"
  end
end

main
