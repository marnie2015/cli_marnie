require_relative '../../app/services/client_query_service'

module ClientTool
  class CLI
    def initialize(args)
      args = args.dup

      @command  = args.shift
      @argument = args.shift
      @field    = 'full_name'
      @source   = 'https://appassets02.shiftcare.com/manual/clients.json'

      while args.any?
        case args.first
        when '--field'
          args.shift
          @field = args.shift
        else
          @source = args.shift
        end
      end
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
          ./bin/client_tool search <query> [source] [--field FIELD]

        Examples:
          ./bin/client_tool search "John"
          ./bin/client_tool search "Jane" path/to/clients.json
          ./bin/client_tool search "jane@example.com" https://example.com/clients.json --field email

      USAGE
    end

    def execute_search
      service = ClientQueryService.new(source: @source, q: @argument, field: @field)
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
