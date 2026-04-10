# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require '../lib/mittens_ui'

class HackerNewsClient
  BASE_URL = 'https://hacker-news.firebaseio.com/v0'

  def self.get_json(path)
    uri = URI("#{BASE_URL}/#{path}")
    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)
  end

  def self.top_story_ids
    get_json('topstories.json')
  end

  def self.get_item(id)
    get_json("item/#{id}.json")
  end

  def self.top_stories(limit = 20)
    top_story_ids.first(limit).map do |id|
      get_item(id)
    end
  end
end

MittensUi::Application.Window(
  name: "hn_viewer",
  title: "HN - Top Hacker News Stories",
  width: 900,
  height: 600
) do

  stories = HackerNewsClient.top_stories()

  rows = stories.map do |story|
    url = story['url'] || "https://news.ycombinator.com/item?id=#{story['id']}"

    [
      story['title'] || 'N/A',
      story['by'] || 'N/A',
      story['score'] || 0,
      url
    ]
  end

  top_stories_table = MittensUi::TableView.new(['Title', 'Author', 'Score', 'URL'].freeze, rows)

  top_stories_table.row_double_clicked do |row|
      link = MittensUi::WebLink.new('', row[3])
      link.open_url
      link.remove
  end
end