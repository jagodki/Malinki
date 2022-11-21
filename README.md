<img src="https://raw.githubusercontent.com/jagodki/Malinki/main/assets/Malinki-Icon.png" width=350/>
Malinki is an app project for publishing spatial data via native mobile apps mainly using OGC-services. The project contains a ready-to-use configurable app prototype for creating map based apps without the necessity of writing code. Just download the repoitory, create a config file and run your map based mobile app.<br>
<p>The following sources of spatial data are currently supported:
  
- WMS
- WMTS
- WFS
- TMS
- GeoJSON (local and remote)
</p>
<i>At the moment, the project contains only a native iOS app.</i>

## Capabilities of the App
Malinki is a mobile app for using spatial data regarding the special requirements and behaviours of smartphones, e.g. small screens, mutlitouch displays and other widely known map apps like Google Maps or Apple Maps. The following screenshots showing data from the example configuration file within this repository. If you want to create your own map app based on Malinki, please create a new configuration file. More information about this can be found in the [documentation section](#documentation).

### Map presentation
The map is covering the whole screen of the device with only three buttons upon the map:<br>
- selecting the basemap and the map theme
- changing the visibility of the map content for the selected map theme
- additional tools like search, bookmarks or personal map markers
<p align="center"><img src="https://raw.githubusercontent.com/jagodki/Malinki/main/assets/Malinki-Capabilities-1.png" width=750/></p>

### Data query
<p>
Malinki offers the posibility to query data for obtaining additional information via map markers above the map. Just like all other map layers, the visibility of map markers can be en- and disabled by the user. The map markers will be provided via the configuration, i.e. the app provider controls the locations to query data. They are always vector data with a WFS or GeoJSON-file as datasource. Technically the data will be queried with a GetFeatureInfo-requests on a WMS, GetFeature-requests on a WFS (using a spatial or ID filter) or directly from a GeoJSON-file (using a spatial or ID filter). The response will be highlighted on the map if it contains a geometry.
</p>
<p>
Malinki offers the posibility to create map pins by the user. These map pins queries data always with a spatial filter on all queryable map layers of the current map theme.
</p>
<p align="center"><img src="https://raw.githubusercontent.com/jagodki/Malinki/main/assets/Malinki-Capabilities-2.png" width=750/></p>

### Search and Spatial Bookmarks
Malinki contains a search for looking up for map themes and map layers. Searching for addresses or map features is not implemented. A map view containing the map theme, the enabled map layers and the position and scale of the map view can be stored in spatial bookmarks. They are stored directly on the device like the user map markers. Each spatial bookmark and user map pin offers some functions after swiping from right to left (rename, update, delete).
<p align="center"><img src="https://raw.githubusercontent.com/jagodki/Malinki/main/assets/Malinki-Capabilities-3.png" width=750/></p>

### Delete Map Cache
All requested map tiles will be stored on the device for the current session (the tiles will be deleted, when the app goes into the background mode) to improve load time if the same tiles have to be displayed again. It is possible, that e.g. a GetMap-request goes wrong and will not return a map tile. In this case the map view cannot show this single map tile. The user has the possibility to delete the whole map cache to force new GetMap-requests.

### In-App-Purchases
The configuration file contains a section to enable or disable in-app-purchases. If in-app-purchases are enabled, the user have to pay for enabling the app functions search, bookmarks and user map markers. These functions are already enabled if in-app-purchases are disabled via the app configuration. The wiki contains a description how to configure the in-app-purchase for the app in the configuration file and in app store connect.

## License
Malinki is published under the terms of Apache-2.0 license.

## Documentation
The documentation for creating a Malinki-based app, writing a valid configuration file in JSON-format, adding assets (e.g. images) to the app, known issues etc. can be found in the <a href="https://github.com/jagodki/Malinki/wiki">wiki</a>.

## Bugs, questions and discussions
Bugs, requests or questions can be reported via <a href="https://github.com/jagodki/Malinki/issues">issues</a>. The repository contains also <a href="https://github.com/jagodki/Malinki/discussions">a board for discussions</a>.

## Version Numbering
**vM.m.b**
- **M** - major releases containing adjustements on the configuration file, e.g. existing config files have to be updated for using a new major release and will be not downward compatible
- **m** - minor releases providing new functions without any effect on existing configurations
- **b** - bug releases for solving bugs without providing new functions or effecting existing configuration files

## Create an app using Malinki
The following steps are mandatory to create a new app based on Malinki:
- download the newest version of Malinki directly from the [release page](https://github.com/jagodki/Malinki/releases)
- extract the content of the downloaded zip archive
- changing the name of the root directory and the Xcode project file is possible, other directories should not be renamed!
- open the target settings within the Xcode project and adjust the **Bundle Identifier** and the **Display Name** at least
- add an app icon named **App Icon**
- create a valid configuration file
- create an accent colour and add all needed images to the assets

## Contributing
Contributions to the project are welcome, especially if anybody will contribute a native or webbased android app. If you are interested in the development of an android app, please contact me via [the discussion board](https://github.com/jagodki/Malinki/discussions) before creating a pull request.

## More information
The project was demonstrated in a talk on the FOSSGIS conference in 2022, the video can be found [here](https://media.ccc.de/v/fossgis2022-13739-malinki-erstellung-kartenbasierter-mobile-apps-ohne-programmierung) (in german language).<br>
The main principles of the app concerning the presentation and interaction with spatial data on a smartphone were presentated at the FOSSGIS conference on 2021, the video can be found [here](https://media.ccc.de/v/fossgis2021-8787-geodaten-auf-smartphones-ein-drittes-paradigma-nach-desktop-und-web-gis) (in german language).
