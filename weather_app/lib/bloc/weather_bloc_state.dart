part of 'weather_bloc.dart';

sealed class WeatherBlocState extends Equatable {
  const WeatherBlocState();

  @override
  List<Object> get props => [];
}

// Define subclasses of WeatherBlocState for different states
class WeatherBlocInitial extends WeatherBlocState {} // Initial state

class WeatherBlocLoading extends WeatherBlocState {} // Loading state

class WeatherBlocFailure extends WeatherBlocState {} // Failure state

class WeatherBlocSuccess extends WeatherBlocState {
  final Weather weather; // Weather data for success state

  const WeatherBlocSuccess(this.weather); // Constructor

  @override
  List<Object> get props => [weather]; // Override props for comparison
}
