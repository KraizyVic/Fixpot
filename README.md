
> [!NOTE]
> 1. Device time should match current time or ssl certificates info will mismatch thus causing errors on the webview.
> 2. Works well with WIFI coz the network_info package only reads wifi data.

# Fixpot
A captive portal opener for both android and TVs.

## How it works:
The app works by passing the device gateway in a webview, If not connected the captive portal redirects you to packages page else it redirects you to router login page

## Prerequisites:
1. Flutter SDK
2. Knowledge in dart programming language

## How to run:
In project folder terminal
1. Run => flutter pub get
2. Run => flutter run
If building an apk run => flutter build apk

## Errors and bugs:
For errors and bugs feel free to open an issue up top
