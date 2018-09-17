//
//  Route.swift
//  eMia
//

import Foundation

enum Route {
  case login
  case settings
  case myProfile(UserModel, String)
  case gallery
  case filter
  case newPost
  case editPost
}
