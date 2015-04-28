

import UIKit

let reuseIdentifier = "gridReuseIdentifier"

class LevelDesignerCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // TODO: Set the layout to our custom layout
        // self.collectionView!.collectionViewLayout = defaultLayout

        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("panHandler:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: Selector("singleTapHandler:"))
        singleTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("longPressHandler:"))
        longPressGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(longPressGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // TODO: Refactor and abstract into constant, currently magic number
        return 10
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Refactor and abstract into constant, currently magic number
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    
        // TODO: Configure the cell
        // Might want to create our own cell class to hold name along with image so that we know
        // what to build into the levels when we do the game start segue
    
        return cell
    }
    
    func panHandler(sender: UIPanGestureRecognizer) {
        let tappedLocation = sender.locationInView(self.collectionView)
        let indexPath = self.collectionView!.indexPathForItemAtPoint(tappedLocation)
        
        // TODO: Update view
    }
    
    func singleTapHandler(sender: UITapGestureRecognizer) {
        let tappedLocation = sender.locationInView(self.collectionView)
        let indexPath = self.collectionView!.indexPathForItemAtPoint(tappedLocation)
        
        // TODO: Update view
    }
    
    func longPressHandler(sender: UILongPressGestureRecognizer) {
        let tappedLocation = sender.locationInView(self.collectionView)
        let indexPath = self.collectionView!.indexPathForItemAtPoint(tappedLocation)
        
        // TODO: Update view
    }
}
