import '../app_exception.dart';
import '../api_client.dart';

class Weather {
  const Weather({
    required this.tempCelsius,
    required this.feelsLikeCelsius,
    required this.condition,
    required this.description,
    required this.icon,
    required this.cityName,
  });

  final double tempCelsius;
  final double feelsLikeCelsius;
  final String condition;
  final String description;
  final String icon;
  final String cityName;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      tempCelsius: (json['tempCelsius'] as num?)?.toDouble() ?? 0,
      feelsLikeCelsius: (json['feelsLikeCelsius'] as num?)?.toDouble() ?? 0,
      condition: json['condition'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
    );
  }

  /// Icon code from OpenWeatherMap mapped to the matching Material icon.
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

/// Proxied through the backend so the weather API key never ships in the
/// client — see server/server.js `/weather`.
class WeatherRepository {
  WeatherRepository(this._client);

  final ApiClient _client;

  Future<Weather> fetchWeather({required double lat, required double lng}) async {
    final response = await _client.get('/weather', query: {
      'lat': lat,
      'lng': lng,
    });
    if (response['success'] != true) {
      throw AppException(response['message'] as String? ?? 'Weather unavailable');
    }
    return Weather.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Weather> fetchWeatherByCity(String city) async {
    final response = await _client.get('/weather', query: {'city': city});
    if (response['success'] != true) {
      throw AppException(response['message'] as String? ?? 'Weather unavailable');
    }
    return Weather.fromJson(response['data'] as Map<String, dynamic>);
  }
}
