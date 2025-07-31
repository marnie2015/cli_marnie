require_relative '../../app/services/client_query_service'

module ClientTool
  class CLI
    def initialize(args)
      @command = args[0]
      @argument = args[1]
      @source = args[2]
    end

    def run
      case @command
      when "search"
        if @argument.nil?
          puts "Error: Missing search query.\n\n"
          print_usage
          exit 1
        end
        execute_search
        exit 0
      else
        puts "Unknown command: #{@command}"
        print_usage
        exit 1
      end
    end

    private

    def print_usage
      puts <<~USAGE

        Usage:
          ./bin/client_tool search <query> [source]

        Examples:
          ./bin/client_tool search "John" https://appassets02.shiftcare.com/manual/clients.json

      USAGE
    end

    def execute_search
      service = ClientQueryService.new(source: @source, q: @argument)
      result = service.process

      matches = result[:results]
      duplicates = result[:duplicates]

      if matches.empty?
        puts "No clients found matching '#{@argument}'."
        return
      end

      display_matches(matches)
      display_duplicates(duplicates) unless duplicates.empty?
    end

    def display_matches(matches)
      matches.each do |client|
        puts "#{client['full_name']} (#{client['email']})"
      end
    end

    def display_duplicates(duplicates)
      puts "\n"
      duplicates.each do |email, clients|
        puts "#{clients.size} clients share the same email (#{email}):"
        clients.each { |c| puts "  - #{c['full_name'] || 'Unnamed'}" }
      end
    end
  end
end
