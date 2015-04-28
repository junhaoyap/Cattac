//
//  GridViewController.swift
//  Cattac
//
//  Created by Wu Di on 28/4/15.
//  Copyright (c) 2015 National University of Singapore (Department of Computer Science). All rights reserved.
//

import Foundation
import UIKit

let gridCellIdentifier = "gridCellIdentifier"

class GridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Current selected palette action
    private var currentAction: String?

    private let rows = Constants.Level.basicRows
    private let columns = Constants.Level.basicColumns
    private var sceneUtils: SceneUtils!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set size of grid area to the size of the container view
        let gridViewWidth = self.view.frame.width
        let gridViewHeight = self.view.frame.height

        sceneUtils = SceneUtils(windowWidth: gridViewWidth, numRows: rows,
            numColumns: columns)

        // Defines the layout for the UICollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = sceneUtils.tileSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let frame = CGRectMake(0, 0, gridViewWidth, gridViewHeight)

        // Initialise the UICollectionView
        let collectionView: UICollectionView = UICollectionView(frame: frame,
            collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self,
            forCellWithReuseIdentifier: gridCellIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()

        // Register gestures
        let panGesture = UIPanGestureRecognizer(target: self,
            action: "panGestureHandler:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        collectionView.addGestureRecognizer(panGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self,
            action: "longPressGestureHandler:")
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)

        self.view = collectionView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated0.
    }

    func numberOfSectionsInCollectionView(
        collectionView: UICollectionView) -> Int {
            return Constants.Level.basicRows
    }

    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return Constants.Level.basicColumns
    }

    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                gridCellIdentifier, forIndexPath: indexPath)
                as UICollectionViewCell

            let tileImage = UIImage(named: "Grass.png")!
            let tile = UIImageView(image: tileImage)
            let tileSize = sceneUtils.tileSize
            tile.frame = CGRectMake(0, 0, tileSize.width, tileSize.height)
            cell.addSubview(tile)
            return cell
    }

    // Used to register single tap on grid
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            println("select \(cell) at \(indexPath)")
    }

    func setCurrentAction(action: String) {
        self.currentAction = action
    }

    func longPressGestureHandler(sender: UILongPressGestureRecognizer) {
        let collectionView = self.view as UICollectionView
        let point: CGPoint = sender.locationInView(self.view)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            println("long select \(cell) at \(indexPath)")
        }
    }

    func panGestureHandler(sender: UIPanGestureRecognizer) {
        let collectionView = self.view as UICollectionView
        let point: CGPoint = sender.locationInView(collectionView)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            println("pan select \(cell) at \(indexPath)")
        }
    }
}