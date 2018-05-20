# eMia-iOS

eMia is an application like a forum. You can post topics with a title, description and a body, attach a photo.
You can register as an user and then sign in. You can edit your profile.
The App will sends you push-notification if another user likes your post.

eMia developed with 
- Firebase database, storage, authentication and cloud messages.
- RxSwift
- RxCocoa + RxDatasource + Custom Layout for UICollectionView
- VIPER

## Requirements

- Xcode 9.2
- Swift 4

## Introduction

If you want to try eMia, sign in your Google account, then open Firebase console https://console.firebase.google.com
Create a new project. Please follow documentations https://firebase.google.com/docs/ios/setup#add_firebase_to_your_app.
As a result you have to download GoogleService-Info.plist file and replace current one.

## Installation

Clone or unzip the repository. Go to the root folder. Make

pod install

Open eMia.xcworkspace

## Notes

Reviewer, please pay attention, the LoginView, GalleryViewController scenes use RxSwift, VIPER

## eMia on Android

Here (https://github.com/SKrotkih/eMia-Android) you can find the eMia Android version.

02-15-2018
