class ApiPaths {
  static const movies = '/movies';
  static String movieDetail(int id) => '/movies/$id';

  static const showtimes = '/showtimes';
  static String seatsByShowtime(int showtimeId) => '/showtimes/$showtimeId/seats';

  static const bookings = '/bookings';

  static const login = '/login';
  static const register = '/register';
  static const logout = '/logout';
  static const me = '/me';
}
