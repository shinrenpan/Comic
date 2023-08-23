//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

/// TabBarController Root 帶有 ScrollView 的 VC
protocol TabScrollableVC: UIViewController {
    var scrollView: UIScrollView { get }
}
