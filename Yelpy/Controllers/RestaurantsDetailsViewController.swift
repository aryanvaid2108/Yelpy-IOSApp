//
//  RestaurantsDetailsViewController.swift
//  Yelpy
//
//  Created by Aryan Vaid on 6/30/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage

class RestaurantsDetailsViewController: UIViewController {


    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    var url = ""
    var reviewsCount = NSNumber()
    var ratingImageName = ""
    var name = "" 
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageURL = URL(string: url)!
        posterView.af.setImage(withURL: imageURL)
        reviewsCountLabel.text = "\(reviewsCount)"
        ratingImage.image = UIImage(named: ratingImageName)
        ratingImage.bringSubviewToFront(self.view)
        nameLabel.text = name
    }
}
