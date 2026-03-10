const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://unifound-backend-vjsb.southeastasia.azurecontainer.io:8080/api',
);
const String loginEndpoint = '/auth/login';
const String logoutEndpoint = '/auth/logout';
const String jwtKey = 'jwt_token';
