# Adir Transport - Complete Backend Setup

This is the complete backend implementation for Adir Transport, a comprehensive transportation platform for Papua New Guinea. The backend is built using Supabase with PostgreSQL, PostGIS for location services, Row Level Security (RLS), and Edge Functions for business logic.

## 🏗️ Architecture Overview

### Tech Stack
- **Database**: PostgreSQL with PostGIS extension for geospatial data
- **Backend**: Supabase (Database, Auth, Real-time, Storage, Edge Functions)
- **Authentication**: Supabase Auth with JWT tokens
- **Real-time**: Supabase Realtime for live driver tracking
- **Storage**: Supabase Storage for file uploads
- **Security**: Row Level Security (RLS) policies

### Services Supported
1. **Ride Booking** - Taxi, hire, lease, and freight services
2. **Flight Booking** - Domestic airline reservations
3. **Accommodation Booking** - Hotels, resorts, lodges
4. **PMV Bus Ticketing** - Local public transport
5. **Payment Processing** - Multiple payment methods
6. **Real-time Tracking** - Driver location tracking
7. **Notifications** - Push notifications and alerts

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Docker (for local Supabase)
- Supabase CLI

### 1. Install Supabase CLI
```bash
npm install -g supabase
```

### 2. Initialize Supabase
```bash
# Start local Supabase
supabase start

# This will create all necessary services:
# - Database: http://localhost:54322
# - API: http://localhost:54321  
# - Studio: http://localhost:54323
# - Inbucket (Email): http://localhost:54324
```

### 3. Environment Setup
```bash
# Copy environment template
cp .env.example .env.local

# Update with your Supabase credentials (shown after supabase start)
```

### 4. Database Setup
```bash
# Run migrations to set up schema
supabase db push

# Or reset and apply seed data
supabase db reset
```

### 5. Deploy Edge Functions (Optional for development)
```bash
# Deploy all edge functions
supabase functions deploy ride-booking
supabase functions deploy flight-booking
supabase functions deploy pmv-booking
supabase functions deploy accommodation-booking
supabase functions deploy driver-tracking
supabase functions deploy payment-processing
```

## 📊 Database Schema

### Core Tables

#### 1. Profiles (User Management)
- Extends Supabase auth.users
- Wallet balance, verification status
- Emergency contacts

#### 2. Drivers
- Driver credentials and verification
- Vehicle information
- Real-time location tracking
- Rating system

#### 3. Bookings (Central Table)
- Unified booking system for all services
- Status tracking (pending → confirmed → in_progress → completed)
- Fare calculation and payment tracking

#### 4. Service-Specific Tables
- **PMV Routes & Tickets**: Bus route management
- **Airlines, Airports & Flights**: Aviation services
- **Accommodation Providers & Rooms**: Hotel bookings
- **Vehicles**: Fleet management

#### 5. Supporting Tables
- **Payments**: Transaction management
- **Notifications**: User alerts
- **Driver Tracking**: Real-time location data
- **Locations**: Common pickup/dropoff points

### Key Features

#### Geospatial Support
- PostGIS extension for location data
- Spatial indexes for performance
- Distance calculations and proximity searches

#### Real-time Capabilities
- Driver location tracking
- Booking status updates
- Live notifications

#### Security
- Row Level Security (RLS) policies
- User data isolation
- Driver-specific access controls

## 🔧 API Endpoints

### Edge Functions

#### 1. Ride Booking (`/functions/v1/ride-booking`)
```json
POST /functions/v1/ride-booking
{
  "service_type": "ride",
  "pickup_address": "Port Moresby CBD",
  "pickup_coordinates": { "lat": -9.4647, "lng": 147.1593 },
  "destination_address": "Jacksons Airport",
  "destination_coordinates": { "lat": -9.4431, "lng": 147.2200 },
  "pickup_time": "2024-01-15T08:00:00Z",
  "passenger_count": 2,
  "vehicle_type": "sedan"
}
```

#### 2. Flight Booking (`/functions/v1/flight-booking`)
```json
POST /functions/v1/flight-booking
{
  "flight_id": "uuid",
  "passenger_name": "John Doe",
  "passenger_email": "john@example.com",
  "travel_date": "2024-01-15",
  "passengers_count": 1
}
```

#### 3. PMV Booking (`/functions/v1/pmv-booking`)
```json
POST /functions/v1/pmv-booking
{
  "route_id": "uuid",
  "passenger_count": 2,
  "travel_date": "2024-01-15",
  "payment_method": "mobile_money"
}
```

#### 4. Driver Tracking (`/functions/v1/driver-tracking`)
```json
POST /functions/v1/driver-tracking
{
  "latitude": -9.4647,
  "longitude": 147.1593,
  "heading": 90,
  "speed_kmh": 45,
  "booking_id": "uuid"
}
```

### Database API (REST)

All tables are accessible via Supabase's auto-generated REST API:

```javascript
// Get available flights
const { data: flights } = await supabase
  .from('flights')
  .select(`
    *,
    airline:airlines(name, iata_code),
    departure_airport:airports!flights_departure_airport_id_fkey(name, city),
    arrival_airport:airports!flights_arrival_airport_id_fkey(name, city)
  `)
  .eq('is_active', true)

// Get user bookings
const { data: bookings } = await supabase
  .from('bookings')
  .select('*')
  .eq('user_id', user.id)
  .order('created_at', { ascending: false })
```

## 🔐 Security & Permissions

### Row Level Security (RLS)

#### User Data Protection
- Users can only see their own bookings and payments
- Drivers can see assigned bookings
- Public read access for reference data (locations, flights, etc.)

#### Sample Policies
```sql
-- Users can view their own bookings
CREATE POLICY "Users can view their own bookings" 
ON public.bookings FOR SELECT 
USING (auth.uid() = user_id);

-- Drivers can view assigned bookings
CREATE POLICY "Drivers can view assigned bookings" 
ON public.bookings FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.drivers 
    WHERE drivers.id = bookings.driver_id 
    AND drivers.user_id = auth.uid()
  )
);
```

## 📱 Frontend Integration

### Supabase Client Setup
```javascript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)
```

### Authentication
```javascript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password',
  options: {
    data: {
      full_name: 'John Doe'
    }
  }
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password'
})
```

### Real-time Subscriptions
```javascript
// Listen to booking updates
const subscription = supabase
  .channel('booking_updates')
  .on('postgres_changes', 
    { 
      event: 'UPDATE', 
      schema: 'public', 
      table: 'bookings',
      filter: `user_id=eq.${user.id}`
    }, 
    (payload) => {
      console.log('Booking updated:', payload)
    }
  )
  .subscribe()

// Driver location tracking
const driverSubscription = supabase
  .channel(`booking_${bookingId}`)
  .on('broadcast', { event: 'driver_location_update' }, (payload) => {
    console.log('Driver location:', payload)
  })
  .subscribe()
```

## 🔧 Development

### Local Development
```bash
# Start Supabase services
supabase start

# View logs
supabase logs

# Reset database (careful - this deletes all data!)
supabase db reset

# Generate TypeScript types
supabase gen types typescript --local > types/supabase.ts
```

### Testing Edge Functions
```bash
# Test locally
supabase functions serve --env-file .env.local

# Invoke function
curl -X POST 'http://localhost:54321/functions/v1/ride-booking' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "service_type": "ride",
    "pickup_address": "Test Location"
  }'
```

## 📈 Monitoring & Analytics

### Built-in Supabase Dashboard
- Real-time database activity
- API usage metrics
- Authentication statistics
- Edge function logs

### Custom Monitoring
- Add logging to edge functions
- Monitor booking conversion rates
- Track driver performance metrics

## 🚀 Production Deployment

### 1. Create Supabase Project
```bash
# Create new project at https://supabase.com
# Get your project URL and keys
```

### 2. Environment Variables
```bash
# Update .env.production with production values
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-production-anon-key
```

### 3. Database Migration
```bash
# Link to production project
supabase link --project-ref your-project-ref

# Push schema to production
supabase db push

# Deploy edge functions
supabase functions deploy --project-ref your-project-ref
```

### 4. Production Considerations
- Set up database backups
- Configure custom SMTP for emails
- Integrate real payment providers
- Set up monitoring and alerts
- Enable SSL and security headers

## 📞 Support & Contributing

### Getting Help
- Check Supabase documentation: https://supabase.com/docs
- PostGIS documentation: https://postgis.net/docs/
- Create issues for bugs or feature requests

### Development Guidelines
- Follow SQL best practices
- Add proper indexes for performance
- Implement comprehensive RLS policies
- Write tests for edge functions
- Document API changes

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

---

Built with ❤️ for Papua New Guinea's transportation needs.
