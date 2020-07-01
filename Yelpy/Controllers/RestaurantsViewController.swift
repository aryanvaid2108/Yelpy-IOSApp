//
//  ViewController.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage
import Lottie
import SkeletonView

class RestaurantsViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var restaurantsArray: [[String:Any?]] = []
    var filteredData: [[String:Any?]] = []
    @IBOutlet weak var searchBar: UISearchBar!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Animation
          startAnimation()
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           self.endAnimation()
        }
        getAPIData()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.sizeToFit()
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        tableView.showAnimatedGradientSkeleton()
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//
//    }
    func startAnimation() {
        animationView.tag = 202
        animationView.animation = Animation.named("food-carousel")
        // Fit the animation
        animationView.contentMode = .scaleAspectFit
        //Set animation to loop
        animationView.loopMode = .loop
        //Set animation speed
        animationView.animationSpeed = 10
        //Play
        animationView.play()
    }
    func endAnimation() {
//        animationView.stop()
        for subview in view.subviews{
            if subview.tag == 202{
                subview.removeFromSuperview()
                }
            }
    }
    
    func getAPIData() {
        API.getRestaurants() { (restaurants) in
        guard let restaurants = restaurants else {
            return
        }
            self.restaurantsArray = restaurants
            self.filteredData = self.restaurantsArray
            self.tableView.reloadData()
        }
    }
    func calcRating(rating: NSNumber) -> String {
        //Parse rating
        var ratingImageName = ""

        switch rating {
        case 0: ratingImageName = "regular_0"
                break
        case 1: ratingImageName = "regular_1"
                break
        case 1.5: ratingImageName = "regular_1_half"
                  break
        case 2: ratingImageName = "regular_2"
                break
        case 2.5: ratingImageName = "regular_2_half"
                  break
        case 3: ratingImageName = "regular_3"
                break
        case 3.5: ratingImageName = "regular_3_half"
                  break
        case 4: ratingImageName = "regular_4"
                break
        case 4.5: ratingImageName = "regular_4_half"
                  break
        case 5: ratingImageName = "regular_5"
                break
        default:
            print("")
        }
        return ratingImageName
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! RestaurantsDetailsViewController
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let restaurant = restaurantsArray[indexPath.row]
        vc.url = restaurant["image_url"] as! String
        let reviewCount = restaurant["review_count"] as! NSNumber
        vc.reviewsCount = reviewCount
        vc.name = restaurant["name"] as! String
        
        let rating = restaurant["rating"] as! NSNumber
        let ratingImageName = calcRating(rating: rating)
        vc.ratingImageName =  ratingImageName
    }
    func getSearchBarResults(searchedName: String) -> [[String:Any]] {
        var results : [[String:Any]] = []
        for item in restaurantsArray {
            //Parse Category
            let categories = item["categories"] as! NSArray
            let temp = categories[0] as! NSDictionary
            let category = temp["title"] as! String
            let name = item["name"] as! String
            if name.contains(searchedName) || category.contains(searchedName){
                results.append(item as [String : Any])
            }
        }
        return results
    }
    
    func loadMoreData() {

        API.getRestaurants() { (restaurants) in
        guard let restaurants = restaurants else {
            return
        }
            for restaurant in restaurants {
                print(restaurant)
                print("XXXXXXXXXXXXX")
            }
            // Update flag
            self.isMoreDataLoading = false

            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
            self.restaurantsArray.append(contentsOf: restaurants) 
            self.filteredData = self.restaurantsArray
            self.tableView.reloadData()
        }
    }
}

extension RestaurantsViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
        tableView.hideSkeleton()
        let restaurant = filteredData[indexPath.row]
        cell.nameLabel.text = restaurant["name"] as? String ?? ""
        
        // Set image
        if let imageURLString = restaurant["image_url"] as? String {
            let imageURL = URL(string: imageURLString)
            cell.posterView.af.setImage(withURL: imageURL!)
        }
        
        let rating = restaurant["rating"] as! NSNumber
        let ratingImageName = calcRating(rating: rating)
        cell.ratingImage.image = UIImage(named: ratingImageName)
        let reviewCount = restaurant["review_count"] as! NSNumber
        cell.ratingNumberLabel.text = "\(reviewCount)"
        cell.phoneLabel.text = restaurant["display_phone"]  as? String ?? ""
        let categories = restaurant["categories"] as! NSArray
        let category = categories[0] as! NSDictionary
        cell.cuisineLabel.text = (category["title"] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension RestaurantsViewController:  UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? restaurantsArray : getSearchBarResults(searchedName: searchText)
        tableView.reloadData()
        }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            filteredData = restaurantsArray
            tableView.reloadData()
    }
}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.style = .medium
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
