<!--

This source file is part of the ENGAGE-HF based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT

-->

# ENGAGE-HF
[![Build and Test](https://github.com/StanfordBDHG/ENGAGE-HF-iOS/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordBDHG/ENGAGE-HF-iOS/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordBDHG/ENGAGE-HF-iOS/graph/badge.svg?token=sFNNo3AoNd)](https://codecov.io/gh/StanfordBDHG/ENGAGE-HF-iOS)

This repository contains the ENGAGE-HF iOS application. ENGAGE-HF builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem, and is primarily written using the [Swift](https://www.swift.org) programming language in conjunction with [SwiftUI](https://developer.apple.com/documentation/swiftui/). The application is developed as part of the DOT-HF study. It records measurements taken on Bluetooth Low Energy peripherals (a weight scale and a blood pressure cuff), saves them to [Firestore](https://firebase.google.com/docs/firestore), and generates medication recommendations based on recent vitals trends and KCCQ-12 survey responses. ENGAGE-HF also allows patients to interact with and manage their measurement history via a Heart Health page built with [Swift Charts](https://developer.apple.com/documentation/charts).

> [!NOTE]
> Do you want to learn more about how to use, extend, and modify this application? Check out the [Stanford Spezi Template Application documentation](https://stanfordspezi.github.io/SpeziTemplateApplication) to get started.


## ENGAGE-HF Features

There are 6 main features of the app: a Home page with a dashboard that displays in-app messages and recent health vitals; a Heart Health page that allows the user to interact with and manage their health data; a Medications page that displays medication recommendations generated by the back-end algorithm; an Education page that features educational videos about the application, the study, and common heart failure medications; a sheet that displays a KCCQ-12 symptom survey; and a sophisticated Bluetooth implementation that allows the user to seamlessly pair bluetooth devices and record measurements without leaving the application.

|![home-screen-less-crowded](https://github.com/user-attachments/assets/2735c038-8abd-4f2d-91fa-fad9dcc5bba0)|![heart-health-weight-graph-overview](https://github.com/user-attachments/assets/f8ec1f2d-8895-4b4b-9161-cd75ed87966f)|![medications-expanded](https://github.com/user-attachments/assets/b627b757-2522-498d-8b67-fdb4fa7b7dd8)|
|:--:|:--:|:--:|
|Home Page|Heart Health|Medications|

|![education-expanded](https://github.com/user-attachments/assets/72def7c7-4f6f-4dfe-bde1-a92f194f5598)|![symptom-survey](https://github.com/user-attachments/assets/42b457a3-7943-4ffd-a5cb-afff16e58df1)|![bluetooth-measurement](https://github.com/user-attachments/assets/50b5f1d9-383d-44b6-9350-7bd135259890)|
|:--:|:--:|:--:|
|Education|Symptom Survey|Bluetooth|


The home page demonstrates that the application is server-driven, as the application displays messages that are generated on the backend. For ENGAGE-HF, this is a [Firebase](https://firebase.google.com/docs) based backend (for more information, see [ENGAGE-HF-Firebase](https://github.com/StanfordBDHG/ENGAGE-HF-Firebase)). To help integrate the backend with our application, we use the standard [Firebase Firestore SDK as defined in the API documentation](https://firebase.google.com/docs/firestore/manage-data/add-data#swift) as well as [SpeziFirebase](https://github.com/StanfordSpezi/SpeziFirebase). Similarly, we manage user account information via [SpeziAccount](https://github.com/StanfordSpezi/SpeziAccount).

The Symptom Survey demonstrates how we can collect survery results from the user from pre-defined surveys. ENGAGE-HF presents the survey using [SpeziQuestionnaire](https://github.com/StanfordSpezi/SpeziQuestionnaire). The survey is stored in Firestore as an [HL-7 FHIR Questionnaire Resource](https://build.fhir.org/questionnaire-definitions.html).

ENGAGE-HF includes sophisticated bluetooth connectivity. Once paired, the app passively collects measurements from BLE peripherals. This is handled via [SpeziBluetooth](https://github.com/StanfordSpezi/SpeziBluetooth), a powerful library that builds on top of [Core Bluetooth](https://developer.apple.com/documentation/corebluetooth).


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

You can find a list of contributors in the [Contributors](https://github.com/StanfordBDHG/ENGAGE-HF-iOS/blob/main/CONTRIBUTORS.md) file.

## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.
