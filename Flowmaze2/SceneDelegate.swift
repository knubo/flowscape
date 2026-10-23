//
//  SceneDelegate.swift
//  Flowmaze2
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("pauseGame"), object: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("restartGame"), object: nil)
    }
}
