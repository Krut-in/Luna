#!/bin/bash
# Test script for Luna Backend API

API_URL="http://localhost:8000"

echo "Testing Luna Backend API Endpoints..."
echo "======================================"
echo

# Test 1: Root endpoint
echo "1. Testing root endpoint (GET /):"
curl -s "$API_URL/" | python3 -m json.tool
echo
echo

# Test 2: Get all venues
echo "2. Testing get venues (GET /venues):"
curl -s "$API_URL/venues" | python3 -m json.tool | head -30
echo "... (output truncated)"
echo

# Test 3: Get specific venue
echo "3. Testing get venue detail (GET /venues/venue_1):"
curl -s "$API_URL/venues/venue_1" | python3 -m json.tool
echo
echo

# Test 4: Get user profile
echo "4. Testing get user profile (GET /users/user_1):"
curl -s "$API_URL/users/user_1" | python3 -m json.tool | head -40
echo "... (output truncated)"
echo

# Test 5: Get recommendations
echo "5. Testing get recommendations (GET /recommendations?user_id=user_1):"
curl -s "$API_URL/recommendations?user_id=user_1" | python3 -m json.tool | head -40
echo "... (output truncated)"
echo

# Test 6: Toggle interest
echo "6. Testing toggle interest (POST /interests):"
curl -s -X POST "$API_URL/interests" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_7", "venue_id": "venue_2"}' | python3 -m json.tool
echo
echo

# Verify interest was added
echo "7. Verify interest was added (GET /venues/venue_2):"
curl -s "$API_URL/venues/venue_2" | python3 -m json.tool
echo
echo

echo "======================================"
echo "Testing complete!"
echo
echo "Database file: Check if luna.db exists"
ls -lh "$HOME/Desktop/Desktop/WEB/webCodes/latestCodee/name/name/Luna-Backend/luna.db" 2>/dev/null || echo "Database file not found"
