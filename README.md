# autocomplete_example

This project is an example project that demonstrates the usage of `google_maps_flutter` to load a map and `googlemaps_flutter_webservices` package to show autocomplete predictions with a search box. It also includes functionality to move the user to the selected place when selecting a suggestion. Additionally, the project implements session tokens using the `UUID` library.

## Getting Started with Google Maps API

To use this project, you'll need a Google Maps API key.

Google provides detailed documentation on how to get started with the Google Maps API, including how to create a project in the Google Cloud Console, enable the necessary APIs, and create an API key.

Please follow the instructions in the [Google Maps Platform Documentation](https://developers.google.com/maps/gmp-get-started) to get your API key.

Once you have your API key, open the project in your code editor. Create a new file in the `lib` directory and name it `api_keys.dart`. In `api_keys.dart`, define a constant for your API key:

    ```dart
    const String googleMapsApiKey = 'YOUR_API_KEY';
    ```

Replace `'YOUR_API_KEY'` with your actual API key.

Remember to add `api_keys.dart` to your `.gitignore` file to prevent your API key from being committed to your version control system. This is important for keeping your API key secure.

Once you have your Google Maps API key, you'll need to add it for other platform implementations also. The process is slightly different for iOS and Android.s

### Android

1. Open the `android/app/src/main/AndroidManifest.xml` file.
2. Look for the following meta-data tag:

   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="API_KEY"/>
   ```

3. Replace `API_KEY` with your actual API key.

### iOS

1. Open the `ios/Runner/AppDelegate.swift` file (or `AppDelegate.m` if your project is using Objective-C).
2. Add the following import at the top of the file:

   ```swift
   import GoogleMaps
   ```

   If your project is using Objective-C, use this import instead:

   ```objective-c
   #import <GoogleMaps/GoogleMaps.h>
   ```

3. Add the following line to the `application:didFinishLaunchingWithOptions:` method:

   ```swift
   GMSServices.provideAPIKey("API_KEY")
   ```

   If your project is using Objective-C, use this line instead:

   ```objective-c
   [GMSServices provideAPIKey:@"API_KEY"];
   ```

4. Replace `API_KEY` with your actual API key.

Remember to keep your API key secure. Do not commit your API key to your version control system.
