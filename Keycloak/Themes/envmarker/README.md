## Environment markers for Keycloak
This is a simple extension of the keycloak.v2 admin theme to display a marker label for the current environment.
![Screenshot](img/screenshot.png?raw=true "Keycloak Backend")

## Installation
* Copy theme directory to <keyclodir>/themes
* Add an environment variable to your deployment on startup script
** ENVMARKER=production
* Add additional css files to <keycloakdir>/themes/envmarker/resources/css
** Replace content and color to your needs.