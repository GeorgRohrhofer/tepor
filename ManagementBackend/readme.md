Keycloak is deployed on https://tozm.net:8080 \
To get the Bearer token which is needed to access the API there are 2 Options:
1. Call the KeyCloak API directly.
	- Post: https://tozm.net:8080/realms/tepor-auth/protocol/openid-connect/token
	- Body -> x-www-form-uriencode:
		- grant_type=password
		- client_id=kekClient
		- username=\<username>
		- password=\<password>
2. Use the Keycloak UI:
	- Go to: https://tozm.net:8080/realms/tepor-auth/account/
	- Login with your username and password
	- The Bearer token can be found in the http Response

You can also register a new user on the Keycloak UI.\
This user will automatically get the "user" role assigned.\
Currently there is only one user with the "admin" role: kek.\
To access the UI and Node Register Endpoint only the user role is needed.
The admin role is only needed to access the TestApi.