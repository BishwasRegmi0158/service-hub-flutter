# ServiceHub — Home Services Booking App

Book home-service professionals — painters, electricians, plumbers,
carpenters, and more. Built with Flutter + Provider.

## Public API used — and an important note

Realistic professional profiles (name, photo, email, phone, location)
come from **RandomUser.me** (`https://randomuser.me/api`) — a free,
public, no-key-needed API.

There is no free public API that actually lists real painters,
electricians, etc. with pricing (services like Thumbtack/Angi/NoBroker
are closed commercial platforms). So this app combines a **real public
API** (for realistic person data) with a **locally-defined list of
trades** (Painter, Electrician, Plumber, Carpenter, Mason, AC
Technician, Gardener, House Cleaner, Locksmith, Appliance Repair).
Each fetched profile is assigned a trade, hourly rate, rating, years of
experience, and bio at fetch time — see `lib/services/api_service.dart`
for exactly how. This is a common, legitimate technique when no public
API exists for your exact domain: pair real API data with your own
business logic on top of it.

**For your report:** be upfront about this — mention that the person
data is from a public API and the trade/pricing data is generated
locally, since no free API tracks home-service categories or rates.

## Features
- **Home** — search professionals by name or trade, tap any card to view details
- **Trades** — grid of service trades (each with an icon), tap to see
  professionals in that trade
- **Cart** — queue up multiple professionals (e.g. a painter AND an
  electrician) and book them together in one form
- **Wishlist** — save favorite professionals locally, survives app restart
- **Profile** — the only place with sign in / sign up. Nothing else in
  the app requires an account.
- **Guest-friendly bookings** — anyone can book without an account. If
  logged in, the booking is tied to that account; if not, it's a guest
  booking. "My Bookings" only shows bookings belonging to whichever
  identity (account or guest) is currently active.

## Setup
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Open this folder in Android Studio or VS Code
3. Run:
   ```
   flutter pub get
   flutter run
   ```

## Project structure
```
lib/
  main.dart                          -> sets up Hive + Provider, launches app
  models/
    professional.dart                -> a bookable professional (API + local data)
    trade.dart                       -> local list of trades (painter, electrician...)
    user_model.dart                  -> a local account
    booking_model.dart               -> a booking, with nullable userId
  services/
    api_service.dart                 -> fetches profiles from RandomUser.me,
                                         assigns trade/price/rating/bio
  providers/
    auth_provider.dart               -> login/signup/logout/session state
    booking_data_provider.dart       -> professionals, cart, wishlist
  screens/
    main_shell.dart                  -> bottom nav: Home/Trades/Cart/Wishlist/Profile
    home_screen.dart                 -> search + professional grid
    trades_screen.dart               -> trade grid
    trade_professionals_screen.dart  -> professionals filtered by trade
    professional_detail_screen.dart  -> bio, rating, wishlist, cart, book now
    cart_screen.dart                 -> queued professionals + checkout
    wishlist_screen.dart             -> saved favorites
    booking_form_screen.dart         -> shared booking form (name/address/date/time)
    my_bookings_screen.dart          -> bookings filtered by current identity
    profile_screen.dart              -> guest/account header, login/signup entry point
    login_screen.dart
    signup_screen.dart
  widgets/
    professional_card.dart           -> reusable card used across grids
```

## Project report
- **Public API:** RandomUser.me — used for realistic professional profile data
- **Domain data:** trades, pricing, ratings, and bios are generated
  locally since no public API exists for home-service listings
- **State management:** Provider (`AuthProvider`, `BookingDataProvider`)
- **Local storage:** Hive — `bookings`, `users`, `session`, `wishlist` boxes
- **Key design decision:** authentication is fully optional; the app
  works end-to-end as a guest, with sign-in only available from Profile
