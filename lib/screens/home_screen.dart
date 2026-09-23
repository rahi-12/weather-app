import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  WeatherModel? weather;

  String city = 'Dhaka';
  String country = 'Bangladesh';

  double latitude = 23.8103;
  double longitude = 90.4125;

  bool isLoading = true;
  String? errorMessage;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    loadWeather();

    _refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => loadWeather(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadWeather() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _weatherService.getWeather(
        latitude,
        longitude,
      );

      if (!mounted) return;

      setState(() {
        weather = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load weather data.';
      });
    }
  }

  Future<void> searchCity() async {
    final name = _searchController.text.trim();

    if (name.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _weatherService.searchCity(name);

      latitude = result['latitude'];
      longitude = result['longitude'];

      city = result['name'];
      country = result['country'] ?? '';

      final newWeather = await _weatherService.getWeather(
        latitude,
        longitude,
      );

      if (!mounted) return;

      setState(() {
        weather = newWeather;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not find this city.';
      });
    }
  }

  String _getWeatherCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1 || code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Cloudy';
    if (code >= 45 && code <= 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';

    return 'Unknown';
  }

  String _getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code == 1 || code == 2) return '🌤️';
    if (code == 3) return '☁️';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌦️';
    if (code >= 95) return '⛈️';

    return '🌡️';
  }

  String _formatTime(String time) {
    final parts = time.split('T');

    if (parts.length < 2) {
      return time;
    }

    final timePart = parts[1];

    final hour = int.parse(timePart.split(':')[0]);
    final minute = int.parse(timePart.split(':')[1]);

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDay(String date) {
    final dateTime = DateTime.parse(date);

    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[dateTime.weekday - 1];
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => searchCity(),
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: const TextStyle(
            color: AppColors.secondaryText,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.green,
          ),
          suffixIcon: IconButton(
            onPressed: searchCity,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.green,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final weatherData = weather!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightGreen,
            AppColors.lightSkyBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.green,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$city${country.isNotEmpty ? ', $country' : ''}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: loadWeather,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            _getWeatherIcon(weatherData.weatherCode),
            style: const TextStyle(
              fontSize: 76,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${weatherData.temperature.round()}°',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _getWeatherCondition(weatherData.weatherCode),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Feels like ${weatherData.feelsLike.round()}°',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    final times = weather!.hourlyTime;
    final temperatures = weather!.hourlyTemperature;
    final codes = weather!.hourlyWeatherCode;

    final count = times.length < 12 ? times.length : 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Hourly Forecast'),

        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              final isFirst = index == 0;

              return Container(
                width: 92,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.green : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isFirst ? AppColors.green : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFirst ? 'Now' : _formatTime(times[index]),
                      style: TextStyle(
                        color: isFirst ? AppColors.white : AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getWeatherIcon(codes[index]),
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      '${temperatures[index].round()}°',
                      style: TextStyle(
                        color: isFirst ? AppColors.white : AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast() {
    final times = weather!.dailyTime;
    final maxTemperatures = weather!.dailyMaxTemperature;
    final minTemperatures = weather!.dailyMinTemperature;
    final codes = weather!.dailyWeatherCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('7-Day Forecast'),

        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: List.generate(
              times.length,
              (index) {
                final isLast = index == times.length - 1;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          index == 0 ? 'Today' : _formatDay(times[index]),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getWeatherIcon(codes[index]),
                        style: const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${maxTemperatures[index].round()}°',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        '${minTemperatures[index].round()}°',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSunCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sunrise',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(weather!.sunrise),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 45,
            color: AppColors.border,
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightSkyBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    color: AppColors.skyBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sunset',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(weather!.sunset),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.red.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.red,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loadWeather,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.green,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.green,
          onRefresh: loadWeather,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  30,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.cloud_rounded,
                              color: AppColors.white,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weather',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  'Your weather, at a glance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: loadWeather,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.lightGreen,
                            ),
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _buildSearchBar(),

                      const SizedBox(height: 24),

                      if (isLoading)
                        _buildLoading()
                      else if (errorMessage != null)
                        _buildError()
                      else if (weather != null) ...[
                        _buildCurrentWeather(),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            _infoCard(
                              icon: Icons.water_drop_rounded,
                              title: 'Humidity',
                              value: '${weather!.humidity}%',
                              iconColor: AppColors.skyBlue,
                            ),
                            const SizedBox(width: 12),
                            _infoCard(
                              icon: Icons.air_rounded,
                              title: 'Wind',
                              value: '${weather!.windSpeed.round()} km/h',
                              iconColor: AppColors.green,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        _buildHourlyForecast(),

                        const SizedBox(height: 28),

                        _buildDailyForecast(),

                        const SizedBox(height: 28),

                        _sectionTitle('Sunrise & Sunset'),

                        _buildSunCard(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
