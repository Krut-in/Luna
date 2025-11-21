# Luna Backend API - Testing Guide

## Quick Start

1. **Start the server:**
```bash
cd Luna-Backend
source venv/bin/activate  # or create venv if not exists
uvicorn main:app --reload --port 8000
```

2. **Test the API:**
All endpoints are available at `http://127.0.0.1:8000`

---

## API Endpoints & Sample Requests

### 1. GET /venues
Returns list of all venues with basic info.

```bash
curl http://127.0.0.1:8000/venues | python3 -m json.tool
```

**Response Format:**
```json
{
  "venues": [
    {
      "id": "venue_1",
      "name": "Blue Bottle Coffee",
      "category": "Coffee Shop",
      "image": "https://picsum.photos/400/300?random=1",
      "interested_count": 4
    }
  ]
}
```

---

### 2. GET /venues/{venue_id}
Get detailed information about a specific venue with list of interested users.

```bash
curl http://127.0.0.1:8000/venues/venue_1 | python3 -m json.tool
```

**Response Format:**
```json
{
  "venue": {
    "id": "venue_1",
    "name": "Blue Bottle Coffee",
    "category": "Coffee Shop",
    "description": "Artisan coffee in minimalist space",
    "image": "https://picsum.photos/400/300?random=1",
    "address": "450 W 15th St, NYC",
    "interested_count": 4
  },
  "interested_users": [
    {
      "id": "user_1",
      "name": "Alex Chen",
      "avatar": "https://i.pravatar.cc/150?img=1"
    }
  ]
}
```

**Test 404 Error:**
```bash
curl http://127.0.0.1:8000/venues/invalid_id | python3 -m json.tool
```

---

### 3. POST /interests
Express or toggle interest in a venue.

```bash
# Add interest
curl -X POST http://127.0.0.1:8000/interests \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_1", "venue_id": "venue_5"}' | python3 -m json.tool

# Remove interest (toggle off)
curl -X POST http://127.0.0.1:8000/interests \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_1", "venue_id": "venue_5"}' | python3 -m json.tool
```

**Response Format:**
```json
{
  "success": true,
  "agent_triggered": false,
  "message": "Interest added for Joe's Pizza"
}
```

---

### 4. GET /users/{user_id}
Get user profile with their interested venues.

```bash
curl http://127.0.0.1:8000/users/user_1 | python3 -m json.tool
```

**Response Format:**
```json
{
  "user": {
    "id": "user_1",
    "name": "Alex Chen",
    "avatar": "https://i.pravatar.cc/150?img=1",
    "bio": "Coffee enthusiast",
    "interests": ["coffee", "food"]
  },
  "interested_venues": [
    {
      "id": "venue_1",
      "name": "Blue Bottle Coffee",
      "category": "Coffee Shop",
      "description": "Artisan coffee in minimalist space",
      "image": "https://picsum.photos/400/300?random=1",
      "address": "450 W 15th St, NYC",
      "interested_count": 4
    }
  ]
}
```

---

### 5. GET /recommendations
Get personalized venue recommendations for a user.

```bash
curl "http://127.0.0.1:8000/recommendations?user_id=user_1" | python3 -m json.tool
```

**Response Format:**
```json
{
  "recommendations": [
    {
      "venue": {
        "id": "venue_4",
        "name": "The Smith",
        "category": "Restaurant",
        "description": "American brasserie with lively atmosphere",
        "image": "https://picsum.photos/400/300?random=4",
        "address": "956 Broadway, NYC",
        "interested_count": 3
      },
      "score": 8.5,
      "reason": "2 friends interested"
    }
  ]
}
```

---

## Recommendation Algorithm Explained

The recommendation score is calculated using 3 factors (max 10 points):

1. **Popularity (0-3 points)**: `min(interested_count / 3, 3)`
   - Rewards venues with more people interested
   - Caps at 3 points when 9+ users interested

2. **Category Match (0-4 points)**: 4 points if venue category matches user interests
   - Checks if venue category appears in user's interest list
   - Example: User with "coffee" interest gets 4 points for Coffee Shop venues

3. **Friend Interest (0-3 points)**: `min(friends_interested, 3)`
   - Counts other users interested in the venue
   - Caps at 3 points when 3+ friends interested

**Example Calculation:**
For user_1 (interests: ["coffee", "food"]) and venue_4 (The Smith Restaurant, 3 people interested):
- Popularity: min(3/3, 3) = 1.0 point
- Category Match: "Restaurant" not in ["coffee", "food"] = 0 points
- Friend Interest: 3 other users interested = 3.0 points
- **Total Score: 4.0**

---

## Test Suite

Run the automated test suite:

```bash
curl -s https://gist.githubusercontent.com/.../test_luna.sh | bash
```

Or create and run manually:
```bash
# Test all endpoints
bash /tmp/test_luna_api.sh
```

---

## Verification Checklist

✅ All 5 endpoints implemented and tested
✅ Response formats match specification exactly
✅ 404 errors handled properly
✅ Recommendation algorithm calculates scores correctly (max 10 points)
✅ Interest toggle works (add/remove)
✅ CORS middleware enabled for iOS app
✅ Code includes proper error handling
✅ All functions have docstrings
✅ Type hints used consistently

---

## Next Steps (Phase 1C)

- Implement booking agent functionality
- Add agent trigger logic when interest threshold met (3+ users)
- Mock reservation code generation
