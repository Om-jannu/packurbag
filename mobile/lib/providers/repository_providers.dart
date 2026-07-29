import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/repositories/ai_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/currency_repository.dart';
import '../data/repositories/discovery_repository.dart';
import '../data/repositories/documents_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/itinerary_repository.dart';
import '../data/repositories/message_repository.dart';
import '../data/repositories/packing_repository.dart';
import '../data/repositories/trip_repository.dart';
import '../data/repositories/weather_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient.instance);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(ref.watch(apiClientProvider)),
);

final itineraryRepositoryProvider = Provider<ItineraryRepository>(
  (ref) => ItineraryRepository(ref.watch(apiClientProvider)),
);

final packingRepositoryProvider = Provider<PackingRepository>(
  (ref) => PackingRepository(ref.watch(apiClientProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(ref.watch(apiClientProvider)),
);

final currencyRepositoryProvider = Provider<CurrencyRepository>(
  (ref) => CurrencyRepository(ref.watch(apiClientProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(ref.watch(apiClientProvider)),
);

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => DiscoveryRepository(ref.watch(apiClientProvider)),
);

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(ref.watch(apiClientProvider)),
);

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DocumentsRepository(),
);

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepository(ref.watch(apiClientProvider)),
);
