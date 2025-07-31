# Client Tool CLI

A Ruby-based command-line tool to search for clients in a JSON dataset by name and detect duplicate emails.

---

## 📦 Setup Instructions

1. ** Clone the repository**

   ```bash
   git clone https://github.com/marnie2015/cli_marnie.git
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
   ./bin/client_tool search "Jane" https://appassets02.shiftcare.com/manual/clients.json
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
