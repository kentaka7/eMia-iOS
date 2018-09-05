# eMia-iOS

![emia](https://user-images.githubusercontent.com/2775621/40444625-88c20db4-5ed2-11e8-8e50-24a8fd0eea0e.gif)

This is my code example. eMia is a simple social network. You can register, edit your profile, then post topics with a title, description, and a photo. You can left comment. It is like a chat.
There are profile editor, push-notification if another user likes your post.

eMia is developing with using following things: 
- Firebase database, storage (for photos), authentication and cloud messages (push-notifications).
- Firebase used for chat implementation
- RxSwift, RxCocoa, RxDatasource 
- RxRealm, RealmSwift
- Custom Layout for UICollectionView
- VIPER

## Requirements

- Xcode 9.3
- Swift 4

## Introduction

To try the eMia, you should beforte 
- sign in your Google account
- open Firebase console https://console.firebase.google.com
- create a new project. Please follow documentation https://firebase.google.com/docs/ios/setup#add_firebase_to_your_app.
- as a result, you have to download GoogleService-Info.plist and replace mine in the root xCode project folder
- also, you should replace Firebase.ServerKey (Constants.swift file ). Take it at the console from the Project settings tab filed "Web API Key" (it is needed for the push-notifications). 

## Installation

- clone or unzip the repository. 
- go to the root folder. 
- launch

   pod install

Open eMia.xcworkspace

## eMia on Android

Please pay attention here (https://github.com/SKrotkih/eMia-Android) you can find the eMia Android version.

05-22-2018
