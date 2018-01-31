--0.99_5for 0.15.8
 - removed oosp not installed detection
 - removed oosp for all consumers
 - reworked code for resourcetraders update
 - removed playerscript handling the (Un-)Loading event
 - removed the timesystem for accurate out-of-sector calculations
 - removed oosProdLib since it's not required anymore
 - remove shipyard oosp update; now http://www.avorion.net/forum/index.php/topic,3910.0.html


--0.99_2d for 0.15.7
 - fixed incompatibility with MineCorp (for real!)


--0.99_2c for 0.15
  - fixed issue with resource depots
  - fixed incompatibility with MineCorp
  - 3 new config options for resource traders


--0.99_2b for 0.15
  - properly added the config, thanks Dirtyredz


--0.99_2 for 0.15
  - update to 0.15
  - uses the production time calculation based on assembly blocks for factories
  - extended config
  - moved to /mods/ folder


--0.9_91 for beta .8782
  [Changes]
  - removed unneccessary Event-unregister, which could cause crashes.


--0.9_9
  [Changes]
  - Changed consumption to better reflect economy


--0.9_8p for beta .8782
  [Changes]
  -Playersectors can be included again: "INCLUDEPLAYERS = true" in /player/oosproduction.lua
  -Problem with not existing Factions has been resolved.


--0.9_8 for beta .8782
  [Changes]
  -The mod does not affect Sectors with Player-property anymore (This excludes the current Playership).
  -All NPC (Trading-)Stations are now fully supported.
  -ResourceDepots now slowly regenerate resources to buy.
  -[inetrnal]changed from a tickbased to a timebased systems
  -The Versioncheck is now off by default


--0.9_7c for beta .7633
  [Changes]
 -Added "IGNOREVESIONCHECK"-variable to ignore the version check some players have problems with. To deactivate the Version check set it to "true".
 -Answers to a version check that exceeded the threshold-time won't be dropped anymore.


--0.9_7b for beta .7633
  [Changes]
Clarified some notions with the Version detection


--0.9_7 for beta .7633
  [Changes]
 divided moveAsteroids into its own mod
make sure you also install the standalone Version of MoveAsteroids or else you might suffer the loss of claimed asteroids:
http://www.avorion.net/forum/index.php/topic,2685.0.html


--0.9_6c for beta .7633
  [Changes]
 reduced logs when factories get updated
 now also players that don't have OOSP installed get a warning that they need to install/update.
  [Bugfixes]
 When a Turretfactory was present in a sector, some factories might not have been updated


--0.9_6b   .7509 beta only
Please note: Don't do a downgrade from 0.9_6b to e.g. 0.9_5
  [Changes]
 getTick/setTick <amount>  added.Admins make sure normal users can't acces setTick!
 I you join a server running 0.9_6 or higher,but have an outdated version. The game will tell you!
  [Bugfixes]
 - [Bug] if for some reason (server crashing etc.) no full server save was executed, it is likely that the galaxytick.txt file was never created and therefore the calculation couldn't be done properly which might feel like the mod is not working.

 - [Bug] when multiple players are online and one leaves, the logoff handling would be triggered for everyone of them.


--0.9_5.
  [Bugfixes]
 [Bug] if for some reason (server crashing etc.) no full server save was executed, it is likely that the galaxytick.txt file was never created and therefore the calculation couldn't be done properly which might feel like the mod is not working.
if you see the following on every serverstart in your serverlog:

  [code]
Wed Feb 08 00:40:38 2017| [OOSP] This is not critical on first start:
Wed Feb 08 00:40:38 2017|  Loading galaxyticks failed: data/scripts/server/tickhandler.lua:34: cannot open file 'galaxyticks.txt' (No such file or directory)[/code]


 - Chances are very high you suffer from this problem.
Only if you show these symptoms place this in data/scripts/server: https://www.dropbox.com/s/pmzol06p4b1n291/tickhandler.lua?dl=1
 - a bug where the ticks weren't saved on the server
 - a bug where removing/taking ressources within in the update process crashed and stopped working for that exact Player (not serverwide)
 - resolved incompatibility with shipyard.lua
 - jumping with multiple Asteroids at the same time caused a servercrash.- This one was hard to fix.


--0.9_2 incompatible to v.0.10.2.7448 and higher
  [Addition]
  added Move Asteroids command to claimed, but neither sold or to-Mine-transformed Asteroids


--0.9_1 incompatible to v.0.10.2.7448 and higher
  [Addition]
  added support for Shipyards
  Consolemessages now have [OOSP] as prefix
  [Bugfixes]
  removed a potential exploit for gaining bonusticks when multiple players enter a loaded sector.


--0.9b
  [Bugfixes]
  fixed a missing dependency which stopped the mod for some palyers


--0.9
release
