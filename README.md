# Where are my cloud files stored?

This is a quick demo for ITEA EASI-CLOUDS that demonstrates a service in which the user can query for the geographical location of their files in a cloud service.

## Getting started

    git clone git@github.com:leonidas/easiclouds-geofiles-demo
    npm install
    npm start
    iexplore http://localhost:9001

## Mock API

Parameters should be URL encoded into the query string. All content is JSON.

* `GET /api/v1/servers`
  * Get the list of all servers in our storage cloud
  * Parameters: none
  * Returns:

    {
      "servers": [
        {
          "hostname": "foo-west.s3.amazonaws.com",
          "coordinates": {
            "lat": 61.525,
            "lng": 24.254
          }
        },
        {
          "hostname": "foo-east.s3.amazonaws.com",
          "coordinates": {
            "lat": 61.525,
            "lng": 21.254
          }
        }
      ]
    }

* `GET /api/v1/files`
  * Get the list of servers that host a particular file
  * Parameters:
    * `url`: The URL of the file whose location you wish to check
  * Returns:

    {
      "url": "https://s3.amazonaws.com/foobucket/barfile.mp3",
      "servers": [
        {
          "hostname": "foo-west.s3.amazonaws.com",
          "coordinates": {
            "lat": 61.525,
            "lng": 24.254,
            "active": true
          }
        }
      ]
    }


## Commands

* npm install
  * Installs server-side dependencies from NPM and client-side dependencies from Bower
* npm start
  * Compiles your files, starts watching files for changes, runs the mock API and servers static files at port 9001
* npm run build
  * Builds & minifies everything

## Enable LiveReload

Install [LiveReload for Chrome](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en)
