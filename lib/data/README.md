# lib/data

Data layer: database, models, and repository implementations shared across
features.

## Contents

- **database/** - Drift database definition, table schemas, DAOs, migrations
- **models/** - Shared data transfer objects (DTOs) and serialization
- **repositories/** - Cross-cutting repository implementations

Feature-specific data classes live in `lib/features/<feature>/data/`.
This folder holds only data infrastructure shared by multiple features.