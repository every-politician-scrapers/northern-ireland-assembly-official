#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'

class MembersList < Scraped::JSON
  field :members do
    json[:AllMembersList][:Member].map { |mem| fragment(mem => MemberItem).to_h }
  end
end

class MemberItem < Scraped::JSON
  field :id do
    json[:PersonId]
  end

  field :name do
    json[:MemberName]
  end

  field :first_name do
    json[:MemberFirstName]
  end

  field :last_name do
    json[:MemberLastName]
  end

  field :party do
    json[:PartyName]
  end

  field :area do
    return constituency unless constituency.include? 'Belfast'

    constituency.split(' ').reverse.join(' ')
  end

  private

  def constituency
    json[:ConstituencyName]
  end

end

url = 'http://data.niassembly.gov.uk/members_json.ashx?m=GetAllCurrentMembers'
data = Scraped::Scraper.new(url => MembersList).scraper.members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
puts header + rows.join
