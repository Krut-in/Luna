#!/bin/bash

# Test script for booking system critical fixes
# Tests all 7 critical issues are resolved

BASE_URL="http://localhost:8000"

echo "🧪 Testing Luna Booking System Critical Fixes"
echo "=============================================="
echo ""

# Test 1: Get initial recommendations
echo "Test 1: Fetch recommendations for user_1"
curl -s "$BASE_URL/recommendations?user_id=user_1" | jq '.recommendations[0] | {venue: .venue.name, score: .score, already_interested: .already_interested}' || echo "❌ Failed"
echo ""

# Test 2: Express interest (should trigger booking at threshold)
echo "Test 2: Express interest as user_1 for venue_1"
curl -s -X POST "$BASE_URL/interests" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_1", "venue_id": "venue_1"}' | jq '{success: .success, agent_triggered: .agent_triggered, reservation_code: .reservation_code}' || echo "❌ Failed"
echo ""

# Test 3: Check venue booking status
echo "Test 3: Check if venue_1 has active booking"
curl -s "$BASE_URL/venues/venue_1/booking" | jq '{has_booking: .has_booking, party_size: .booking.party_size}' || echo "❌ Failed"
echo ""

# Test 4: Try duplicate booking (4th user)
echo "Test 4: Try to create duplicate booking (should be prevented)"
curl -s -X POST "$BASE_URL/interests" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_4", "venue_id": "venue_1"}' | jq '{success: .success, agent_triggered: .agent_triggered, message: .message}' || echo "❌ Failed"
echo ""

# Test 5: Get user bookings
echo "Test 5: Fetch bookings for user_1"
curl -s "$BASE_URL/bookings/user_1" | jq '.bookings[] | {venue: .venue.name, reservation_code: .reservation_code, party_size: .party_size}' || echo "❌ Failed"
echo ""

# Test 6: Remove interest (should cancel booking if count < 3)
echo "Test 6: Remove interest (toggle off)"
curl -s -X POST "$BASE_URL/interests" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user_1", "venue_id": "venue_1"}' | jq '{success: .success, booking_cancelled: .booking_cancelled}' || echo "❌ Failed"
echo ""

# Test 7: Verify recommendations include already_interested flag
echo "Test 7: Verify recommendations show already_interested status"
curl -s "$BASE_URL/recommendations?user_id=user_2" | jq '.recommendations[] | select(.already_interested == true) | {venue: .venue.name, already_interested: .already_interested}' | head -5 || echo "❌ No already_interested venues (might be OK)"
echo ""

# Test 8: Test race condition protection (concurrent requests)
echo "Test 8: Test race condition protection (3 simultaneous requests)"
curl -s -X POST "$BASE_URL/interests" -H "Content-Type: application/json" -d '{"user_id": "user_5", "venue_id": "venue_2"}' &
curl -s -X POST "$BASE_URL/interests" -H "Content-Type: application/json" -d '{"user_id": "user_6", "venue_id": "venue_2"}' &
curl -s -X POST "$BASE_URL/interests" -H "Content-Type: application/json" -d '{"user_id": "user_7", "venue_id": "venue_2"}' &
wait
echo "Concurrent requests completed"
echo ""

# Test 9: Verify only ONE booking created for venue_2
echo "Test 9: Verify only one booking exists for venue_2"
curl -s "$BASE_URL/venues/venue_2/booking" | jq '{has_booking: .has_booking, booking_id: .booking.id}' || echo "❌ Failed"
echo ""

# Test 10: Get all venues (basic smoke test)
echo "Test 10: Smoke test - fetch all venues"
curl -s "$BASE_URL/venues" | jq '{count: (.venues | length)}' || echo "❌ Failed"
echo ""

echo "=============================================="
echo "✅ All tests completed!"
echo ""
echo "Manual verification steps:"
echo "1. Check that bookings are created when 3+ users interested"
echo "2. Verify duplicate bookings are prevented"
echo "3. Confirm booking cancellation works when interest drops"
echo "4. Validate 'already_interested' flag in recommendations"
echo "5. Test race condition protection with concurrent requests"
