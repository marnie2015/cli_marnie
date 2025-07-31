# Client Tool CLI

A Ruby-based command-line tool to search for clients in a JSON dataset by name and detect duplicate emails.

---

## 📦 Setup Instructions

1. **Clone the repository**

   ```bash
   git clone git@github.com:marnie2015/cli_marnie.git
   cd cli_marnie

   ```

2. **Install dependencies**

Make sure you have Ruby and Bundler installed:

```
gem install bundler
bundle install
```

3. **Make the CLI script executable**

   _Note: (Run this also if you get a "permission denied" error when trying to run the CLI.)_

   ```
   chmod +x bin/client_tool
   ```

4. **Usage**
   Run the CLI with the search command followed by a query and an optional JSON file path (defaults to `https://appassets02.shiftcare.com/manual/clients.json`):

   ```
   ./bin/client_tool search "<query>" [source_file]
   ```

5. **Example**

   ```
   ./bin/client_tool search "Jane"

   OR

   ./bin/client_tool search "Jane" path/to/clients.json
   ```

6. **Expected Output**

   ```
   Jane Smith (jane@example.com)

   2 clients share the same email (jane@example.com):
    - Jane Smith
    - Another Jane Smith

   ```

## ✅ Assumptions & Design Decisions

- Client data is stored in a flat JSON array of objects.
- Each client has a `full_name` and `email` field.
- Only a search command is supported for now.
- Duplicate detection is based on exact email matches.
- Focused on simplicity and minimal dependencies.

## ⚠️ Known Limitations

- No fuzzy or partial matching (simple case-sensitive substring).
- Doesn't handle malformed or deeply nested JSON.
- Loads the entire JSON into memory — not ideal for large files.
- No output formatting (e.g. CSV, JSON export).
- No pagination or sorting of results.

## 🧪 Running Tests

This project uses [RSpec](https://rspec.info/) for automated testing.

To run all tests with human-readable output, use:

```bash
bundle exec rspec --format documentation
```

## 🌐 Feature Improvements

- Implement a REST API using Sinatra or Rails for web-based querying.
- Add the ability to specify which field to search, such as `email`.
- Enable exporting results to JSON or CSV format.
- Add pagination and sorting to large result sets.
- Introduce versioning for both API endpoints (e.g., `/api/v1/...`) and service logic to support future enhancements without breaking compatibility.

## 📈 Scalability Considerations

- Move from file-based JSON parsing to a database-backed model using PostgreSQL.
- Add caching (e.g., in-memory memoization or Redis) for repeated queries.
- Use background jobs for expensive operations (e.g. de-duplication or export).
