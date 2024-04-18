import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/data/my_data.dart'; // Import data file that has the api

part 'weather_bloc_event.dart'; // Import event classes
part 'weather_bloc_state.dart'; // Import state classes

class WeatherBloc extends Bloc<WeatherBlocEvent, WeatherBlocState> {
  WeatherBloc() : super(WeatherBlocInitial()) {
    on<FetchWeather>((event, emit) async {
      // Emit the loading state before fetching weather data
      emit(WeatherBlocLoading());
      try {
        // Create a WeatherFactory instance with yourzzzzz API key
        WeatherFactory wf = WeatherFactory(API_KEY, language: Language.ENGLISH);

        // Fetch current weather by location using Geolocation
        Weather weather = await wf.currentWeatherByLocation(
          event.position.latitude,
          event.position.longitude,
        );
        // Emit success state with fetched weather data
        emit(WeatherBlocSuccess(weather));
      } catch (e) {
        // Emit failure state if an error occurs during data fetching
        emit(WeatherBlocFailure());
      }
    });
  }
}
