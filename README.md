# SMSRouter

Forward Android newly received sms to a specific Google Spreadsheet

## Getting Started

### Google Spreadsheet Backend

- Follow [this tutorial](https://medium.com/mindorks/storing-data-from-the-flutter-app-google-sheets-e4498e9cda5d) to set up backend API endpoint
- Note the specific fields in the google app script
- Note that you have to publish new version to update your changes in GA script to server
- Can use [BetterLog](https://github.com/peterherrmann/BetterLog) to log data to a spreadsheet for debugging

### Flutter setup

1. Rename the `sms_mapping.example.json` to `sms_mapping.json` & update your desired regex & api endpoint
2. Update the data model in `SmsPayload` as needed (delete unused fields & update param names)
3. Run the app, and you should see newly arrived sms

- Note that there's a testing function in `main.dart` from `initState()`
