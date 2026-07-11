# lib/data/database

Drift database definitions and data access objects (DAOs).

## Contents

- **database.dart** - Main AppDatabase class, connection setup
- **tables/** - Drift table class definitions
- **daos/** - Data access objects for grouped queries
- **migrations/** - Schema migration strategy

## Setup

The database uses SQLite via `package:sqlite3` and `package:drift`.
On desktop platforms (Windows/macOS), `path_provider` locates the database
file. The connection uses `NativeDatabase` from drift.