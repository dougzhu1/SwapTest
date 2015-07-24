//
//  VerticalViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 11/17/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit

class VerticalViewController: UIViewController, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var imagesForSection0: [UIImage] = []
    var timelineImages = [PFObject]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RAReorderableLayout"
        let nib = UINib(nibName: "verticalCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadImages()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)
    }
    
    // RAReorderableLayout delegate datasource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let threePiecesWidth = floor(screenWidth / 3.0 - 1.0)
        return CGSizeMake(threePiecesWidth, threePiecesWidth)

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 2.0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

            return self.timelineImages.count

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("verticalCell", forIndexPath: indexPath) as! RACollectionViewCell
        
        //cell.imageView.image = self.imagesForSection0[indexPath.item]
        
        let topImage = self.timelineImages[indexPath.item]
        let topImageFile = topImage["imageFile"] as! PFFile
        topImageFile.getDataInBackgroundWithBlock { (imageData:NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    cell.imageView.image = image!
                    var tap = UITapGestureRecognizer(target: self, action: Selector("imageTapped"))
                    cell.imageView.addGestureRecognizer(tap)
                    cell.imageView.userInteractionEnabled = true
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView.numberOfItemsInSection(indexPath.section) <= 1 {
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, atIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        var photo: UIImage
        
        photo = self.imagesForSection0.removeAtIndex(atIndexPath.item)

        self.imagesForSection0.insert(photo, atIndex: toIndexPath.item)
    
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        return 0
    }
    
    func scrollTrigerPaddingInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.collectionView.contentInset.top, 0, self.collectionView.contentInset.bottom, 0)
    }
    
    func loadImages() {
        timelineImages.removeAll(keepCapacity: false)
        var query = PFQuery(className: "Photos")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            //Append objects in the DB Into timlineImages
            if error == nil {
                if let myObjects = objects as? [PFObject]{
                    for messageObject in myObjects {
                        self.timelineImages.append(messageObject)
                    }
                    self.collectionView.reloadData()
                }
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func refresh() {
        loadImages()
    }
    
    func imageTapped() {
    
    }
}

class RACollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    override var highlighted: Bool {
        didSet {
            self.hilightedCover.hidden = !self.highlighted
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.hilightedCover.frame = self.bounds
        self.applyGradation(self.imageView)
    }
    
    private func configure() {
        self.imageView = UIImageView()
        self.imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.imageView)
        
        self.hilightedCover = UIView()
        self.hilightedCover.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.hilightedCover.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.hilightedCover.hidden = true
        self.addSubview(self.hilightedCover)
    }
    
    private func applyGradation(gradientView: UIView!) {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = nil
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.frame = gradientView.bounds
        
        let mainColor = UIColor(white: 0, alpha: 0.3).CGColor
        let subColor = UIColor.clearColor().CGColor
        self.gradientLayer!.colors = [subColor, mainColor]
        self.gradientLayer!.locations = [0, 1]
        
        gradientView.layer.addSublayer(self.gradientLayer)
    }
}