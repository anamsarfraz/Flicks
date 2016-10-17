//
//  DetailViewController.swift
//  Flicks
//
//  Created by Unum Sarfraz on 10/13/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {
    @IBOutlet weak var posterView: AFNetworking.UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    var movie: NSDictionary!
    
    @IBOutlet weak var movieScrollView: UIScrollView!
    
    @IBOutlet weak var overviewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize navigation bar
        self.navigationItem.title = "Movie Details"
        posterView.frame.size.height -= (self.tabBarController?.tabBar.frame)!.height
        overviewView.frame.origin.y -= (self.tabBarController?.tabBar.frame)!.height
        // Add a scroll view
        movieScrollView.contentSize = CGSize(width: movieScrollView.frame.size.width, height: overviewView.frame.origin.y + overviewView.frame.size.height)
        self.titleLabel.text = "\(movie["title"] as? String ?? "")"
        self.titleLabel.sizeToFit()
        self.overviewLabel.text = "\(movie["overview"] as? String ?? "")"
        self.overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            /*let posterBaseUrl = "https://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            self.posterView.setImageWith(posterUrl! as URL)
            */
            loadPosterImage(posterPath: posterPath)
        } else {
            // No poster image. Set it to default image
            self.posterView.image = UIImage(named: "UnavailableImage")
        }

    }

    func loadPosterImage(posterPath: String) {
        let lowResPosterBaseUrl = "https://image.tmdb.org/t/p/w45"
        let highResPosterBaseUrl = "https://image.tmdb.org/t/p/original"
        
        let smallImageRequest = URLRequest(url: URL(string: lowResPosterBaseUrl+posterPath)!)
        let largeImageRequest = URLRequest(url: URL(string: highResPosterBaseUrl+posterPath)!)
        
        posterView.setImageWith(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.posterView.alpha = 0.0
                self.posterView.image = smallImage;
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    self.posterView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterView.setImageWith(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // failed to get large image, set to default image
                                self.posterView.image = UIImage(named: "UnavailableImage")
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
                self.posterView.image = UIImage(named: "UnavailableImage")
        })

    }
}
