"""  
Data models for Luna venue discovery application.

This module defines the core Pydantic models for users, venues, and interests.
All models use Pydantic for automatic validation and serialization.

MODELS:
    User: Represents a user with profile information and interests
    Venue: Represents a physical location/venue users can discover
    Interest: Represents a many-to-many relationship between users and venues

VALIDATION:
    - All models use Pydantic's BaseModel for automatic validation
    - String fields are automatically validated for type
    - Datetime fields ensure proper timestamp handling
    - List fields validate element types

SERIALIZATION:
    - Models automatically serialize to JSON for API responses
    - Snake_case naming matches Python conventions
    - DateTime fields serialize to ISO8601 format

USAGE:
    from models import User, Venue, Interest
    
    user = User(
        id="user_1",
        name="John Doe",
        avatar="https://example.com/avatar.jpg",
        bio="Coffee lover",
        interests=["coffee", "food"]
    )
"""

from datetime import datetime
from typing import List
from pydantic import BaseModel
class User(BaseModel):
    """
    User model representing a person using the venue discovery app.
    
    Attributes:
        id: Unique identifier for the user
        name: Full name of the user
        avatar: URL to user's avatar image
        bio: Short biography or description
        interests: List of interest categories (e.g., "coffee", "food")
    """
    id: str
    name: str
    avatar: str
    bio: str
    interests: List[str]


class Venue(BaseModel):
    """
    Venue model representing a place users can discover and visit.
    
    Attributes:
        id: Unique identifier for the venue
        name: Name of the venue
        category: Category type (e.g., "Coffee Shop", "Restaurant")
        description: Detailed description of the venue
        image: URL to venue's image
        address: Physical address of the venue
    """
    id: str
    name: str
    category: str
    description: str
    image: str
    address: str


class Interest(BaseModel):
    """
    Interest model representing a user's interest in a specific venue.
    
    Attributes:
        user_id: ID of the user expressing interest
        venue_id: ID of the venue the user is interested in
        timestamp: When the interest was expressed
    """
    user_id: str
    venue_id: str
    timestamp: datetime


class Booking(BaseModel):
    """
    Booking model representing an automated reservation for a venue.
    
    Created when interest threshold is met (3+ users interested).
    Tracks reservation details and status to prevent duplicate bookings.
    
    Attributes:
        id: Unique identifier for the booking
        venue_id: ID of the venue being booked
        user_ids: List of user IDs included in the booking
        reservation_code: Mock reservation code (e.g., "LUNA-venue_1-1234")
        created_at: Timestamp when booking was created
        status: Current booking status ("active", "cancelled")
    """
    id: str
    venue_id: str
    user_ids: List[str]
    reservation_code: str
    created_at: datetime
    status: str  # "active" or "cancelled"
