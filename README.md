weather
=======

The maritime weather information from Marine Weather Service Hamburg is only available through the website http://www.dwd.de/ and without static links.

This Script gets the content part 'Wettervorhersagen für die Strecke Engl. Kanal - Gibraltar'

Uses mechanize to navigate on DWD page, parse content and write file named with UTC time to distinct from new data.
