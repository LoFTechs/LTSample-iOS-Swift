# LT SDK for iOS sample
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)

[![cocoapods](https://img.shields.io/cocoapods/v/LTSDK)](https://github.com/LoFTechs/LTSDK-iOS)


## Introduction

With LT SDK, you can build your own customized application with Call and IM function. This documentary provides a guideline that demonstrates how to build and configure an in-app message and call using LT SDK.


## Getting started

This section explains the steps you need to take before testing the iOS sample app.


## Installation

To use our iOS sample, you should first install [LTSample for iOS](https://github.com/LoFTechs/LTSample-iOS-Swift) 1.0.0 or higher.
### Requirements

|Sample|iOS|
|---|---|
| LTSample |1.0.0 or higher|


### LT Sample

You can **clone** the project from the [LTSample repository](https://github.com/LoFTechs/LTSample-iOS-ObjectiveC). 

```
// Clone this repository
git clone git@github.com:LoFTechs/LTSample-iOS-Swift.git

// Move to the LT sample
cd LTSample-iOS-Swift/

// Install LT SDK
pod install
```

### Install LT SDK for iOS

You can install LT SDK for iOS through `cocoapods`.

To install the pod, add following line to your Podfile:


```
pod 'LTSDK'
pod 'LTCallSDK'
pod 'LTIMSDK'
``` 

Set Develop api data and password to `LTSample-iOS/Config/Config.plist`.

```properties
Brand_ID="<YOUR_BRAND_ID>"
Auth_API="<YOUR_AUTH_API>"
LTSDK_API="<YOUR_LTSDK_API>"
LTSDK_TurnKey="<YOUR_LTSDK_TURNKEY>"
Developer_Account="<YOUR_DEVELOPER_ACCOUNT>"
Developer_Password="<YOUR_DEVELOPER_PASSWORD>"
License_Key="<YOUR_LINCENSE_KEY>"
``` 
