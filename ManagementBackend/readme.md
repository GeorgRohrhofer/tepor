To use this app you need to download and install keycloak locally (or run in a docker).
Use realm-export.json config file to load the realm, clients and users.
To get the Bearer token from Keycloak make the following request (with Postman):
POST: http://localhost:8080/realms/tepor-auth/protocol/openid-connect/token
Body -> x-www-form-uriencode:
Key			Value
grant_type	password
client_id	kekClient
username	kek
password	kek

This is a test user and will not be used in production for obvious safety reasons.
After making this request you will receive the bearer token.
When making a request to the API (e.g. GET: https://localhost:4444/WeatherForecast)
paste the Token under Authorization -> Bearer Token.