# MotoSpeedo
A rain aware motorcycle speedometer

MotoSpeedo is a speedometer app designed for use on old motorcycles. It features a very clear high contrast readout with no extraneous features to distract the rider. On startup the app checks the DarkSky API for rain within the next 12 hours - enough time to cover both ends of a typical commute - and warns the rider with a rain icon. It also features a simple trip meter that warns the rider when they are approaching a specified distance. This is intended to be used as a fuel indicator, where a rider knows the typical mileage they might get from a tank rather than looking at an unreliable or non existent fuel gauge. Users are also able to choose their icon to match the colours of some popular brands. 


### Availabilty
MotoSpeedo is available on the [iOS App Store](https://itunes.apple.com/au/app/motospeedo/id1326611362?mt=8) as a tier 2 paid app (AU$2.99, US$1.99, GB£1.99).

### Dependencies
MotoSpeedo relies on the [DarkSky API](https://darksky.net/dev). You'll need to create your own account and API key if you are running from source. Add a file to contain your API Key for DarkSky which contains the following line 
```
let DS_KEY = "YOUR_API_KEY_HERE" 
```
