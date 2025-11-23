# Luna Backend - SQLite Database Version

## Quick Start

```bash
# Install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run server
python3 run_server.py
```

Server runs at: `http://0.0.0.0:8000`

## What's New

✅ **SQLite Database** - Data persists across restarts  
✅ **28 Friendships** - All user pairs are friends  
✅ **Venue Coordinates** - Latitude/longitude for all 12 NYC venues  
✅ **Action Items** - Persist in database  
✅ **Zero iOS Changes** - API responses identical  

## API Endpoints (Unchanged)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Health check |
| GET | `/venues` | List all venues |
| GET | `/venues/{id}` | Get venue details |
| POST | `/interests` | Toggle interest |
| GET | `/users/{id}` | Get user profile |
| GET | `/recommendations` | Get recommendations |
| POST | `/action-items/{id}/complete` | Complete action item |
| DELETE | `/action-items/{id}` | Dismiss action item |

## Database

- **File:** `luna.db` (92 KB)
- **Type:** SQLite 3.x
- **Tables:** users, venues, interests, user_interests, friendships, action_items
- **Data:** 8 users, 12 venues, 25 interests, 28 friendships

## Testing

```bash
# Run automated tests
chmod +x test_api.sh
./test_api.sh

# Or test manually
curl http://localhost:8000/venues
```

## Reset Database

```bash
# Delete database and restart server
rm luna.db
python3 run_server.py
# Data will be re-seeded automatically
```

## Files

- `main.py` - API endpoints (database version)
- `database.py` - Database configuration
- `models/db_models.py` - SQLAlchemy models
- `models/api_models.py` - Pydantic API models
- `seed_data.py` - Initial data seeding
- `run_server.py` - Server startup script
- `main_old.py` - Backup (in-memory version)

## Dependencies

```txt
fastapi==0.115.0        # Web framework
uvicorn==0.32.0         # ASGI server
pydantic==2.9.0         # Data validation
sqlalchemy==2.0.35      # Database ORM
aiosqlite==0.20.0       # Async SQLite
greenlet==3.1.1         # Async support
```

## Documentation

See `MIGRATION_COMPLETE.md` for full migration details and technical documentation.

## iOS App

**No changes required!** All API responses maintain identical structure.
