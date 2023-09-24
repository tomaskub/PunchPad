# ClockIn
A simple app helping to track time at work 

# Description 
ClockIn helps with tracking the work time and overtime you do at work. Whenever the time sheet fails at work, or something on the paycheck does not add up you can confirm with the app and make sure you are getting paid fairly. Additionally - you can plan ahead and make sure you know how much you are going to get paid so you can budget accordingly. 

# Main screens 
| Onboarding | Timer - recording worktime | Timer - recording overtime | Settings |
|---|---|---|----|
|![ClockIn-onboardingGif](https://user-images.githubusercontent.com/7796745/234943438-3721fe96-70e8-4e75-b080-aa91e9c38e04.gif)| ![ClockIn-WorkTimer-Short](https://user-images.githubusercontent.com/7796745/234945116-6af2ddc6-1480-49d5-a6f1-d670615fcb1b.gif)| ![ClockIn-OvertimeTimerShort](https://user-images.githubusercontent.com/7796745/234947721-81337c2c-ea6a-4af5-95fb-a4ac3dfc2544.gif)|![ClockIn-SettingsView](https://user-images.githubusercontent.com/7796745/234946206-391a1fe6-415e-4cf4-ab83-bdb1c447a549.gif)|

# Statistics, pay calculation and editing entries 
| Statistics | Adding Entry Manually | Editing Entry | Removing Entry |
|------------|-----------------------|---------------|----------------|
|![ClockIn-StatisticsView](https://user-images.githubusercontent.com/7796745/234949318-e4706609-920b-4bd6-a9a5-3bf6b194076e.gif)|![ClockIn-AddingentryManually](https://user-images.githubusercontent.com/7796745/234949357-f900e103-ec4b-424b-b4f9-61d2f5a18605.gif)|![ClockIn-EditingEntryManually](https://user-images.githubusercontent.com/7796745/234949370-d96429b4-1ac2-47fa-8ed0-0b4bfd9959cc.gif)|![ClockIn-RemovingEntryManually](https://user-images.githubusercontent.com/7796745/234949385-6dd95432-5500-47bc-b9cd-96c8c1c86005.gif)|

# Technologies
- SwiftUI
- MVVM architecture 
- Combine
- Charts 
- CoreData
- UI and unit teseted with XCTest

# Highlights 
- DI is done with root container passed into environment. Services are retrieved from container and injected into subviews. Container is responsible for parsing launch arguments, detecting previews and configuring the environment, making UI testing much easier. 
- SettingsStore wraps user defaults and provides a type safe access to the settings. It also is a single point of acess and shares state with multiple view models, ensuring that all parts of the app work on the same set of data.
- RingView shows passsing time in intuitive manner
- DataManager allows to create easy previews and easy testing
- TimerModel has injected TimerProvider with metatypes allows for easy testing in XCTest with mock timer.

# Build 
No external dependencies - clone and run 

# Feedback 
Feel free to file an issue or submit a PR. Im always looking to improve my work. 
