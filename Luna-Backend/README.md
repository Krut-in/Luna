# Quick Start Guide - Luna Backend

## Start Server
```bash
cd Luna-Backend
source venv/bin/activate
uvicorn main:app --reload --port 8000
```

## Test All Endpoints
```bash
# 1. List all venues
curl http://127.0.0.1:8000/venues | python3 -m json.tool

# 2. Get venue detail
curl http://127.0.0.1:8000/venues/venue_1 | python3 -m json.tool

# 3. Express interest
curl -X POST http://127.0.0.1:8000/interests \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user_1","venue_id":"venue_5"}' | python3 -m json.tool

# 4. Get user profile
curl http://127.0.0.1:8000/users/user_1 | python3 -m json.tool

# 5. Get recommendations
curl "http://127.0.0.1:8000/recommendations?user_id=user_1" | python3 -m json.tool
```

## API Documentation
Browse interactive docs at: http://127.0.0.1:8000/docs

## Project Structure
```
Luna-Backend/
├── main.py              # All 5 API endpoints + recommendation logic
├── models.py            # Pydantic models (User, Venue, Interest)
├── data.py              # Synthetic test data (8 users, 12 venues)
├── requirements.txt     # Python dependencies
├── API_TESTING.md       # Complete testing guide
└── PHASE_1B_SUMMARY.md  # Implementation verification
```

## Phase 1B Status: ✅ COMPLETE
- 5 API endpoints implemented and tested
- Recommendation algorithm working correctly
- CORS enabled, error handling in place
- All response formats match specification
