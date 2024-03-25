## Environment markers for Keycloak
This is a simple extension of the keycloak.v2 admin theme to display a marker label for the current environment.
<br/><br/>
![Screenshot](img/screenshot.png?raw=true "Keycloak Backend")

## Installation
* Copy theme directory to <keycloakdir>/themes or add the admin folder to your existing custom theme.
* Add an environment variable to your deployment or startup script (or start.sh/bat for local development).
    * ENVMARKER=production
    * Out of the box values:
        * development (green)
        * test (blue)
        * staging (yellow)
        * production (red) (default)
* Add additional css files to "<keycloakdir>/themes/envmarker/resources/css".
    * Replace content and color to your needs.

```css
/* admin/resources/css/production.css */
.pf-c-page__header:after {
    background: red;
    content: "Production";   
}
```
