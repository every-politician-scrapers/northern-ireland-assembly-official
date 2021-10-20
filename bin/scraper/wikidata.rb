#!/bin/env ruby
# frozen_string_literal: true

require 'cgi'
require 'csv'
require 'scraped'

class Results < Scraped::JSON
  field :members do
    json[:results][:bindings].map { |result| fragment(result => Member).to_h }
  end
end

class Member < Scraped::JSON
  field :id do
    json.dig(:id, :value)
  end

  field :item do
    json.dig(:item, :value).to_s.split('/').last
  end

  field :label do
    json.dig(:itemLabel, :value)
  end

  field :area do
    json.dig(:areaLabel, :value)
  end

  field :party do
    json.dig(:partyLabel, :value)
  end

  field :first_name do
    json.dig(:givenLabel, :value)
  end

  field :last_name do
    json.dig(:familyLabel, :value)
  end
end

WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql?format=json&query=%s'

memberships_query = <<SPARQL
  SELECT DISTINCT ?id ?item ?itemLabel ?partyLabel ?areaLabel ?givenLabel ?familyLabel {
     ?item p:P39 ?ps .
     ?ps ps:P39 wd:Q37279107 .
     FILTER NOT EXISTS { ?ps pq:P582 [] }
     OPTIONAL { ?item wdt:P5870 ?id }
     OPTIONAL { ?ps pq:P4100 ?party }
     OPTIONAL { ?ps pq:P768 ?area }
     OPTIONAL { ?item wdt:P735 ?given }
     OPTIONAL { ?item wdt:P734 ?family }
     SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
  }
  ORDER BY xsd:integer(?id) ?itemLabel
SPARQL

url = WIKIDATA_SPARQL_URL % CGI.escape(memberships_query)
headers = { 'User-Agent' => 'every-politican-scrapers/northern-ireland-assembly-official' }
data = Results.new(response: Scraped::Request.new(url: url, headers: headers).response).members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
