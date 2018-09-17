# eMia-iOS

![emia](https://user-images.githubusercontent.com/2775621/40444625-88c20db4-5ed2-11e8-8e50-24a8fd0eea0e.gif)

eMia is a simple social network. Sign up or sign in, edit your profile, enter new post with a title, description, and  photo. You can search or filter other posts, browse, comment them. If you like post the other user will get push-notification about that.

The iOS eMia app developed with using following things: 
- Firebase authentication and database
- Firebase storage
- Firebase cloud messages (push-notifications)
- RxSwift, RxCocoa, RxDatasource 
- RxRealm, RealmSwift
- Custom Layout for UICollectionView
- VIPER, MVVM
- etc (new iOS 11 features like 3D touch on the app home screen icon )

## Requirements

- Xcode 9.3
- Swift 4

## Pre-Installation

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

## eMia on Android and React Native

Here https://github.com/SKrotkih/eMia-Android you can see eMia for Android,
and here https://github.com/SKrotkih/eMia the eMia version for React Native.

Last update on 09-11-2018
