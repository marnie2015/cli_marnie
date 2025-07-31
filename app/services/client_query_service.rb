require 'json'
require 'open-uri'

class ClientQueryService
  def initialize(source:, q:)
    @clients = load_clients(source)
    @query = q
  end

  def process
    results = search_by_name(@query)
    duplicates = find_duplicate_emails(results)

    {
      results: results,
      duplicates: duplicates
    }
  end

  private

  def load_clients(source)
    data = if source =~ /\Ahttps?:\/\//
             URI.open(source).read
           else
             File.read(source)
           end

    JSON.parse(data)
  end

  def search_by_name(query)
    return [] if query.nil? || query.strip.empty?

    @clients.select do |client|
      full_name = client['full_name']
      full_name && full_name.downcase.include?(query.downcase)
    end
  end

  def find_duplicate_emails(clients)
    grouped = clients.group_by { |c| c['email'] }
    grouped.select { |email, list| email && list.size > 1 }
  end
end
