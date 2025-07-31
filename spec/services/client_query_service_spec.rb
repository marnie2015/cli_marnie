require 'rspec'
require_relative '../../app/services/client_query_service'

RSpec.describe ClientQueryService do
  let(:mock_data) do
    [
      { 'full_name' => 'Jane Smith', 'email' => 'jane@example.com' },
      { 'full_name' => 'Another Jane Smith', 'email' => 'jane@example.com' },
      { 'full_name' => 'John Doe', 'email' => 'john@example.com' }
    ]
  end

  before do
    allow(File).to receive(:read).and_return(mock_data.to_json)
  end

  describe '#process' do
    context 'when query matches some clients with duplicate emails' do
      subject { described_class.new(source: 'fake.json', q: 'Jane') }

      it 'returns the matching clients and correct duplicates', :aggregate_failures do
        result = subject.process
        expect(result[:results].map { |c| c['full_name'] }).to contain_exactly(
          'Jane Smith',
          'Another Jane Smith'
        )
        expect(result[:duplicates].keys).to contain_exactly('jane@example.com')
        expect(result[:duplicates]['jane@example.com'].size).to eq(2)
      end
    end

    context 'when query matches clients without duplicates' do
      subject { described_class.new(source: 'fake.json', q: 'John') }

      it 'returns the matching client and no duplicates', :aggregate_failures do
        result = subject.process
        expect(result[:results].map { |c| c['full_name'] }).to eq(['John Doe'])
        expect(result[:duplicates]).to be_empty
      end
    end

    context 'when query matches no clients' do
      subject { described_class.new(source: 'fake.json', q: 'ZZZ') }

      it 'returns empty results and duplicates', :aggregate_failures do
        result = subject.process
        expect(result[:results]).to be_empty
        expect(result[:duplicates]).to be_empty
      end
    end

    context 'when query is nil' do
      subject { described_class.new(source: 'fake.json', q: nil) }

      it 'returns empty results and duplicates', :aggregate_failures do
        result = subject.process
        expect(result[:results]).to be_empty
        expect(result[:duplicates]).to be_empty
      end
    end

    context 'when query is blank string' do
      subject { described_class.new(source: 'fake.json', q: '   ') }

      it 'returns empty results and duplicates', :aggregate_failures do
        result = subject.process
        expect(result[:results]).to be_empty
        expect(result[:duplicates]).to be_empty
      end
    end

    context 'when full_name is missing in one client' do
      before do
        broken_data = mock_data + [{ 'email' => 'no_name@example.com' }]
        allow(File).to receive(:read).and_return(broken_data.to_json)
      end

      subject { described_class.new(source: 'fake.json', q: 'no_name') }

      it 'does not raise an error and ignores the client with nil full_name' do
        expect { subject.process }.not_to raise_error
        result = subject.process
        expect(result[:results]).to be_empty
      end
    end
  end
end
