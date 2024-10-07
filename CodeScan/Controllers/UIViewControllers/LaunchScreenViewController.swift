
import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var viewLoader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
        let faceVC = MainStoryBoard.instantiateViewController(withIdentifier: "FirstViewVC") as? FirstViewVC
        self.navigationController?.pushViewController(faceVC!, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }    
}
