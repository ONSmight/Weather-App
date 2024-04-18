part of 'weather_bloc.dart';

sealed class WeatherBlocEvent extends Equatable {
  const WeatherBlocEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherBlocEvent {
  final Position position; // Position for fetching weather data

  const FetchWeather(this.position);

  @override
  List<Object> get props => [position]; // Override props for comparison
}
