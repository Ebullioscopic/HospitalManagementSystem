//import UIKit
//import SwiftUI
//
//class DoctorDashboardViewController: UIViewController {
//    
//    private let doctorId: String
//    
//    init(doctorId: String) {
//        self.doctorId = doctorId
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Create SwiftUI view
//        let dashboardView = DoctorDashboard(doctorId: doctorId)
//        
//        // Host SwiftUI view in UIKit
//        let hostingController = UIHostingController(rootView: dashboardView)
//        
//        // Add as child view controller
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        hostingController.didMove(toParent: self)
//        
//        // Make hosted view fill the parent view
//        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
//            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//}
