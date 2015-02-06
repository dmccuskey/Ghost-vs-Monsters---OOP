## Ghost vs Monsters OOP 2.0 ##

The original Ghosts vs. Monsters was a physics-based game template designed for mobile devices. It was created by Jonathan Beebe and Biffy Beebe for Corona SDK (http://coronalabs.com).

This repo contains the complete app _Ghost vs Monsters_ re-written in an object-oriented style of programming. It's intended as a example of how one might separate functionality within a Corona mobile application.

This new version is modernized for changes over past three years – new Corona SDK engine, DMC Corona Libraries, as well as my coding style. :)

Many thanks to everyone at Beebe Games and Corona Labs for making the code publicly available!

### Highlights ###

* Simplification of level data
* **new** Fully G2 Compatible
* **new** now uses Corona Composer (removed Director lib)
* **new** uses new dmc-widgets for buttons (removed UI lib, dmc-buttons lib)
* **new** update dmc-objects to 2.0
* **new** re-organized files into folders
* **new** some Component Objects moved to own files (cloud, ghost, monster) (loading overlay, pause overlay, game-over overlay)
* **new** improved overall code organization
* **new** heavy use of OOP and State Pattern
* **new** example of global communication via dmc-megaphone (can be enabled)
* **new** managers created for Sounds, Levels (non-visual)
* **new** new App Controller: controls core app setup and scene navigation
* **new** new Test Controller: enables full Component test development
* **new** only 3 global variables


### More Information ###

*This version*

Details about the changes: http://docs.davidmccuskey.com/display/docs/Ghosts+vs+Monsters+Details

*Original version*

* Intro: http://blog.anscamobile.com/2010/12/ghosts-vs-monsters-open-source-game-in-corona-sdk/

* Github: https://github.com/ansca/Ghosts-vs.-Monsters


### Misc ###

This app is likely to be used as the small-app template in my git repo for [Corona App Templates](https://github.com/dmccuskey/Corona-App-Templates)
