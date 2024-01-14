# ClockIn
A simple app helping to track time at work 

# Description 
ClockIn helps with tracking the work time and overtime you do at work. Whenever the time sheet fails at work, or something on the paycheck does not add up you can confirm with the app and make sure you are getting paid fairly. Additionally - you can plan ahead and make sure you know how much you are going to get paid so you can budget accordingly. 

# Main screens 
| Main screen with timer | Statistics | Settings |
|---|---|---|
|![main](https://github.com/tomaskub/ClockIn/assets/7796745/15353843-d69d-4194-9f86-81666bc37baa)|![statistics](https://github.com/tomaskub/ClockIn/assets/7796745/9aef0c58-45cd-4295-9b9c-f2d95d0449e2)|![settings](https://github.com/tomaskub/ClockIn/assets/7796745/6763214b-a16f-4a78-9a51-c21dad4c5171)|



# Editing data screens 
| History | Entry editing | Entry filtering |
|------------|-----------------------|---------------|
|![History](https://github.com/tomaskub/ClockIn/assets/7796745/dfb2f03e-99c5-4876-bf4c-a427be1ab514)|![editsheet](https://github.com/tomaskub/ClockIn/assets/7796745/fa1f2fcd-ea76-4723-9eb0-deb04ea6fc9c)|![filtering](https://github.com/tomaskub/ClockIn/assets/7796745/74f0ef87-6b47-44ca-bcb1-68e93f4269ec)|



# Technologies
- SwiftUI
- MVVM architecture 
- Combine
- Charts 
- CoreData
- UI and unit tested with XCTest

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

