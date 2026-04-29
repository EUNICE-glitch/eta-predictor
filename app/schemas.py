# app/schemas.py
from pydantic import BaseModel, Field

class ETARequest(BaseModel):
    origin_lat: float = Field(..., ge=-90, le=90, description='Origin latitude')
    origin_lon: float = Field(..., ge=-180, le=180, description='Origin longitude')
    dest_lat: float = Field(..., ge=-90, le=90, description='Destination latitude')
    dest_lon: float = Field(..., ge=-180, le=180, description='Destination longitude')
    cargo_weight_kg: float = Field(..., gt=0, le=20000, description='Cargo weight in kg')
    hour_of_day: int = Field(..., ge=0, le=23, description='Hour of departure')
    num_stops: int = Field(1, ge=1, le=20, description='Number of delivery stops')