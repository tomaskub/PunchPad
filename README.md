# PunchPad
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



# Project structure 
Project is seperated into several layers, following modular architecture approach highlighted by Cyril Cermak in his [Modular architecture on iOS](https://github.com/CyrilCermak/modular_architecture_on_ios).
Since the work does miss a chapter on swift project manager implementtion, i decided to use that here. It is not the cleanest and still in the polishing phase.

## Structure
```
|-- Core
    |-- DomainModels
    |-- FoundationExtensions
    |-- Persistance 
    |-- UIComponents 
    |-- XCTestExtensions
|-- Services
    |-- ChartPeriodService
    |-- NotificationService
    |-- PayService
    |-- SettingsService
    |-- TimerService
|-- Domains 
    |-- Home
    |-- History
    |-- Onboarding
    |-- Settings
    |-- Statistics
|-- Composition Root
    |-- Navigation
    |-- Main target app
```
## Notes on structure 
Below is list of notes on some decisions i made during the modularization effort. I attemp to provide rationale behind it, as well as possible alternatives.
### Micro-splitting of services
Each service should have three corresponding packages:
  - interfaces with protocol definition of the service
  - main with implementation
  - mocks with support for testing
This approach helps with tracing the dependencies between services - which can happen. In this approach the service implementation depends on service interfaces, rather than implementations. That solves the circular dependency problem, and promotes dependecy injection and inversion of control - all implementations are injected from composition root, or domains layer. As an alternative, an approach to place all of the interfaces in `Core` layer would work also - either in `DomainModels` or in seperate package like `DomainInterfaces`. It would provide less granuality, but reduce overhead when definiting packages.
### Domains and Services vs Features

This project opts for a **Core-Services-Domains-Root** structure over a simpler **Core-Feature-Root** approach.
*   **Clearer Separation:** The `Domains` layer encapsulates distinct user-facing parts of the application (e.g., Home, History, Settings). This creates a better separation between:
    *   **User-facing features (`Domains`):** Standalone parts of the UI and user flows.
    *   **Internal capabilities (`Services`):** Reusable logic and integrations (e.g., PayService, TimerService).
*   **Improved Testability:**
    *   This separation allows UI testing to be scoped within specific `Domains`, focusing on particular user flows.
    *   It facilitates partial testing on CI services. By building only the necessary `Domain` modules based on Pull Request diffs, we can potentially run a subset of UI tests, speeding up the CI process.

In contrast, a simpler "Feature" based approach often mixes user-facing features and internal services at the same level, potentially leading to less clear boundaries and dependencies.

# Technologies
- SwiftUI
- MVVM architecture 
- Combine
- Charts 
- CoreData
- UI and unit tested with XCTest
- Xcode Cloud for CI tests
- SPM
- XCodeGen

# Highlights 
- Dependencies are local swift packages imported into the main app project.
- DI is done with root container passed into environment. Services are retrieved from container and injected into subviews. Container is responsible for parsing launch arguments, detecting previews and configuring the environment, making UI testing much easier. 
- SettingsStore wraps user defaults and provides a type safe access to the settings. It also is a single point of acess and shares state with multiple view models, ensuring that all parts of the app work on the same set of data.
- RingView shows passsing time in intuitive manner
- DataManager allows to create easy previews and easy testing
- TimerModel has injected TimerProvider with metatypes allows for easy testing in XCTest with mock timer.

# Build 

To build the project, follow these steps:

1.  **Install Dependencies:**
    Make sure you have [Homebrew](https://brew.sh/) installed. Then, install SwiftLint and XcodeGen:
    ```bash
    brew install swiftlint xcodegen
    ```

2.  **Generate Xcode Project:**
    Navigate to the project's root directory in your terminal and run XcodeGen:
    ```bash
    xcodegen generate
    ```
    This will create the `PunchPad.xcodeproj` file.

3.  **Open and Build:**
    Open the generated `PunchPad.xcodeproj` file in Xcode. You can then build and run the project using the standard Xcode build process (select a simulator or device and press Cmd+R).

**Note:** SwiftLint will run automatically as a build phase to check code style.

# Feedback 
Feel free to file an issue or submit a PR. Im always looking to improve my work. 

