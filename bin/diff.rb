#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

# Remove government members and standardise parties
class Comparison < EveryPoliticianScraper::Comparison
  REMAP = {
    'People Before Profit' => 'People Before Profit Alliance',
    'Alliance Party of Northern Ireland' => 'Alliance Party',
    'Green Party in Northern Ireland' => 'Green Party',
    'independent politician' => 'Independent',
  }.freeze

  def wikidata_csv_options
    { converters: [->(val) { REMAP.fetch(val, val) }] }
  end
end

diff = Comparison.new('data/wikidata.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
