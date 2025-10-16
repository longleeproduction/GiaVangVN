import SwiftUI

public extension UIApplication {
    
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        
        return viewController
    }

    var topMostViewController: UIViewController? {
        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
              return nil
        }
        
        var topMostViewController = currentScene.windows.first?.rootViewController
        while topMostViewController?.presentedViewController != nil {
            topMostViewController = topMostViewController?.presentedViewController
        }
        
        return topMostViewController
    }
    
    var isTopMostViewControllerPresented: Bool {
        return topMostViewController?.isViewControllerPresented ?? false
    }
    
    var appIcon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    func getRootViewController() -> UIViewController {

        guard let screen = self.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }

        return root
    }

}

public extension UIViewController {
    
    var isViewControllerPresented: Bool {
        if presentedViewController != nil {
            return true
        } else if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.isViewControllerPresented ?? false
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.isViewControllerPresented ?? false
        }
        return false
    }
}
