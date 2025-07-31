
require 'open3'
require 'tempfile'
require 'json'

RSpec.describe 'ClientTool CLI' do
  let(:cli_path) { File.expand_path('../../../bin/client_tool', __FILE__) }

  def run_cli(*args)
    Open3.capture3("ruby", cli_path, *args)
  end

  def create_json_file(data)
    file = Tempfile.new(['clients', '.json'])
    file.write(JSON.pretty_generate(data))
    file.rewind
    file
  end

  let(:clients) do
    [
      { "full_name" => "Jane Smith", "email" => "jane@example.com" },
      { "full_name" => "John Smith", "email" => "john@example.com" },
      { "full_name" => "Jane Smith", "email" => "jane@example.com" }
    ]
  end

  describe 'CLI behavior' do
    it 'prints usage when no command is provided' do
      stdout, stderr, status = run_cli
      expect(stdout).to include("Usage:")
      expect(status.exitstatus).not_to eq(0)
    end

    it 'prints error and usage if search query is missing' do
      stdout, _, status = run_cli("search")
      expect(stdout).to include("Missing search query")
      expect(stdout).to include("Usage:")
      expect(status.exitstatus).not_to eq(0)
    end

    it 'prints error for unknown command' do
      stdout, _, status = run_cli("unknown")
      expect(stdout).to include("Unknown command")
      expect(status.exitstatus).not_to eq(0)
    end

    it 'executes search with valid query and no duplicates' do
      file = create_json_file([
        { "full_name" => "Jane Smith", "email" => "jane@example.com" },
        { "full_name" => "John Smith", "email" => "john@example.com" }
      ])

      stdout, _, status = run_cli("search", "Jane", file.path)
      expect(stdout).to include("Jane Smith (jane@example.com)")
      expect(stdout).not_to include("share the same email")
      expect(status.exitstatus).to eq(0)
    end

    it 'executes search with duplicates' do
      file = create_json_file(clients)
      stdout, _, status = run_cli("search", "Jane", file.path)
      expect(stdout).to include("Jane Smith (jane@example.com)")
      expect(stdout).to include("2 clients share the same email")
      expect(status.exitstatus).to eq(0)
    end

    it 'prints message when no clients match the query' do
      file = create_json_file(clients)
      stdout, _, status = run_cli("search", "Nonexistent", file.path)
      expect(stdout).to include("No clients found matching 'Nonexistent'")
      expect(status.exitstatus).to eq(0)
    end
  end
end
