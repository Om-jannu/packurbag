# Packurbag

Packurbag is your travel companion — plan trips with itineraries, packing lists, and budgets, get destination weather, translate on the go, connect with nearby travelers, and reach help fast with emergency SOS.

## Repo layout

This is a monorepo with three independent projects:

```
mobile/   Flutter app (iOS, Android, web, desktop)
server/   Node backend (Hono + MongoDB)
web/      Next.js marketing site
```

## Features

- **Trips**: plan trips with destinations, dates, notes, and a budget
- **Itinerary**: day-by-day activities per trip, with priority and location
- **Packing lists**: checklists with quick-apply templates (Beach, Hiking, Business, General)
- **Budget tracking**: log expenses in any currency, converted automatically
- **Travel documents vault**: passport/visa/ticket/insurance references, stored only on-device
- **Destination weather** and a **home currency snapshot** on the dashboard
- **Nearby Travelers**: opt-in geolocation discovery of other registered travelers, with 1:1 chat
- **AI Travel Assistant**: destination-aware trip advice
- **Currency Converter** and **Language Translation**
- **Emergency SOS**: countdown, slide-to-cancel, auto-dial + location-sharing SMS to your emergency contact

## Getting started

### Backend (`server/`)

```bash
cd server
npm install
```

Create a `.env` file in `server/`:

```
MONGO_URL="mongodb+srv://<username>:<password>@<cluster>.mongodb.net/packurbag"
PORT=5000
OPEN_EXCHANGE_RATES_APP_ID=""
OPENAI_API_KEY=""
WEATHER_API_KEY=""
```

The last three are optional — currency conversion, the AI Travel Assistant, and destination weather each degrade gracefully with a clear "not configured" message if their key is missing.

Run it:

```bash
npm run dev
```

### Mobile app (`mobile/`)

The project pins its own Flutter SDK as a git worktree at `mobile/.flutter-sdk` so builds are reproducible regardless of what Flutter version you have installed globally.

```bash
cd mobile
./.flutter-sdk/bin/flutter pub get
./.flutter-sdk/bin/flutter run -d chrome
```

Point it at a different backend (e.g. a real device hitting a local server via ngrok) with:

```bash
./.flutter-sdk/bin/flutter run --dart-define=API_BASE_URL=https://your-server
```

### Marketing site (`web/`)

```bash
cd web
npm install
npm run dev
```

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature`)
3. Make your changes
4. Commit your changes (`git commit -am 'Add new feature'`)
5. Push to the branch (`git push origin feature`)
6. Create a new Pull Request.
