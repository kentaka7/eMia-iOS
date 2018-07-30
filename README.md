# eMia-iOS

![emia](https://user-images.githubusercontent.com/2775621/40444625-88c20db4-5ed2-11e8-8e50-24a8fd0eea0e.gif)

This is my code example. eMia is a simple social network. You can register, then post topics with a title, description and a photo.
There are profile editor, push-notification if another user likes your post.

eMia is developing with using following things: 
- Firebase database, storage (for photos), authentication and cloud messages (push-notifications).
- RxSwift, RxCocoa, RxDatasource 
- RxRealm, RealmSwift
- Custom Layout for UICollectionView
- VIPER

## Requirements

- Xcode 9.3
- Swift 4

## Introduction

If you want to try eMia, sign in your Google account, then open Firebase console https://console.firebase.google.com
Create a new project. Please follow documentation https://firebase.google.com/docs/ios/setup#add_firebase_to_your_app.
As a result, you have to download GoogleService-Info.plist and replace mine in root folder. Also, you should replace 
Firebase.ServerKey. Take it at the console from the Project settings tab filed "Web API Key" (it is needed for the push-notifications). 

## Installation

- clone or unzip the repository. 
- go to the root folder. 
- make

   pod install

Open eMia.xcworkspace

## eMia on Android

Here (https://github.com/SKrotkih/eMia-Android) you can find the eMia Android version.

05-22-2018
