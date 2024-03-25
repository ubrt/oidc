## Environment markers for Keycloak
This is a simple extension of the keycloak.v2 admin theme to display a marker label for the current environment.
![Screenshot](img/screenshot.png?raw=true "Keycloak Backend")

## Installation
* Copy theme directory to <keyclodir>/themes or add the admin folder to your existing custom theme.
* Add an environment variable to your deployment on startup script.
    * ENVMARKER=production
    * Out of the box values:
        * development (green)
        * test (blue)
        * staging (yellow)
        * production (red)
* Add additional css files to "<keycloakdir>/themes/envmarker/resources/css".
    * Replace content and color to your needs.

```css
.pf-c-page__header:after {
    background: red;
    content: "Production";   
}
```