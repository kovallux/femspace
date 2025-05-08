import UIKit
import SwiftUI // Required for UIHostingController and AIChatView

class AIChatViewController: UIViewController {

    // Instantiate the ViewModel here. It will be owned by this ViewController.
    private let chatViewModel = AIChatViewModel()
    private var hostingController: UIHostingController<AIChatView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SwiftUI view with the ViewModel
        let chatSwiftUIView = AIChatView(viewModel: chatViewModel)
        
        // Create a UIHostingController to host the SwiftUI view
        let hostingVC = UIHostingController(rootView: chatSwiftUIView)
        self.hostingController = hostingVC // Keep a reference
        
        // Add the hosting controller as a child view controller
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        
        // Set up constraints for the hosting controller's view
        // to fill the safe area of this view controller
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Set the title for the navigation bar (if this VC is embedded in a UINavigationController)
        // This title will be picked up by the UINavigationController.
        self.navigationItem.title = "AI Chat"
        
        // Configure Navigation Bar Appearance
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // Or .configureWithDefaultBackground() or .configureWithTransparentBackground()
            appearance.backgroundColor = UIColor(red: 237/255.0, green: 22/255.0, blue: 81/255.0, alpha: 1.0)
            
            // Optional: Customize title text attributes if needed
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            // For compact appearance (e.g. landscape on iPhone)
            self.navigationController?.navigationBar.compactAppearance = appearance 
            // For compact scroll edge appearance (iOS 15+)
            if #available(iOS 15.0, *) {
                 self.navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
            }
        }
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allow other touches (e.g., on TextField or Button) to pass through
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // If you need to pass data or refresh the view when the tab becomes visible:
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Example: Refresh chat or check for new messages if needed
        // chatViewModel.refreshChatDataIfNeeded()
    }
    */
}

// Note: If your project doesn't have a bridging header or if these Swift files are not automatically
// recognized by Objective-C, you might need to ensure that your Objective-C code
// can see this Swift class. Usually, Xcode generates a header like `YourProjectName-Swift.h`
// which you can import in your Objective-C files (`#import "YourProjectName-Swift.h"`).
// Make sure this AIChatViewController class is marked as `@objc public class AIChatViewController ...` or has methods exposed with `@objc`
// if you intend to instantiate or call it directly from Objective-C code beyond just setting it in a storyboard.
// However, since you plan to assign this ViewController to a Tab in the Storyboard, you just need to make sure
// the class name is set correctly in the Storyboard's Identity Inspector for the new ViewController.
// You would typically set the "Class" to "AIChatViewController" and "Module" to your project name (or leave it blank if it's in the main target). 
