//
//  ViewController.swift
//  Flicks
//
//  Created by Unum Sarfraz on 10/11/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorWarningImage: UIImageView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    @IBOutlet weak var viewSelectorControl: UISegmentedControl!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var searchActive : Bool = false
    var filteredSearch:[NSDictionary] = []
    var moviesInfo: [NSDictionary]?
    var endPoint: String!
    var viewSelection: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        moviesCollectionView.contentInset = UIEdgeInsetsMake(0, 0, (self.tabBarController?.tabBar.frame)!.height*2.4, 0)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchPosts), for: UIControlEvents.valueChanged)

        errorLabel.text = "Network Error"
        errorView.isHidden = true
        moviesSearchBar.isHidden = false
        errorWarningImage.image = UIImage(named: "WarningImage")
        moviesCollectionView.alwaysBounceVertical = true
        viewSelection = [moviesTableView, moviesCollectionView]

        // Set up both UIViews: TableView and CollectionView
        for i in 0..<viewSelection.count {
            if (i == viewSelectorControl.selectedSegmentIndex) {
                viewSelection[i].isHidden = false
                viewSelection[i].insertSubview(refreshControl, at: 0)
            } else {
                viewSelection[i].isHidden = true
            }
            viewSelection[i].backgroundColor = UIColor(red:0.95, green:0.80, blue:0.10, alpha:1.0)
        }
        
        // Customize navigation bar
        self.navigationItem.titleView = moviesSearchBar
        let backButtonTitle = viewSelectorControl.selectedSegmentIndex == 0 ? "List": "Grid"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.95, green:0.80, blue:0.10, alpha:0.8)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.gray.withAlphaComponent(0.5)
        shadow.shadowOffset = CGSize(width: 2, height: 2);
        shadow.shadowBlurRadius = 4;
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22),
            NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.6, blue: 0.5, alpha: 0.8),
            NSShadowAttributeName : shadow
        ]
        
        fetchPosts(refreshControl:refreshControl)
    }
    
    @IBAction func tapOutsideSearch(_ sender: AnyObject) {
        moviesSearchBar.endEditing(true)
        view.removeGestureRecognizer(tapRecognizer)
    }
    func processMovieData(responseData: NSDictionary?) -> Void {
        moviesInfo = responseData?["results"] as! [NSDictionary]?
        errorView.isHidden = true
        moviesSearchBar.isHidden = false
        
        if (viewSelectorControl.selectedSegmentIndex == 0) {
            moviesTableView.reloadData()
        } else {
            moviesCollectionView.reloadData()
        }
    }
    
    func displayError(error: NSError?) -> Void {
        errorView.isHidden = false
        moviesSearchBar.isHidden = true
    }
    
    func fetchPosts(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endPoint ?? "")?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            if let requestError = errorOrNil {
                self.displayError(error: requestError as NSError?)
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        self.processMovieData(responseData: responseDictionary)
                    }
                }
            }
            
            refreshControl.endRefreshing()
            
        });
        task.resume()
    }
  
    
    @IBAction func viewSelectionChanged(_ sender: AnyObject) {
        var refreshSubView: UIView?
        
        for i in 0..<viewSelection.count {
            if (i == viewSelectorControl.selectedSegmentIndex) {
                viewSelection[i].isHidden = false
            } else {
                viewSelection[i].isHidden = true
                for subview in viewSelection[i].subviews {
                    if ((subview as? UIRefreshControl) != nil) {
                        subview.removeFromSuperview()
                        refreshSubView = subview
                    }
                }
            }
        }
        
        viewSelection[viewSelectorControl.selectedSegmentIndex].insertSubview(refreshSubView!, at: 0)
        let backButtonTitle = viewSelectorControl.selectedSegmentIndex == 0 ? "List": "Grid"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)

        if (viewSelectorControl.selectedSegmentIndex == 0) {
            moviesTableView.reloadData()
        } else {
            moviesCollectionView.reloadData()

        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        moviesSearchBar.becomeFirstResponder()
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        filteredSearch.removeAll()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredSearch = moviesInfo!.filter({ (movieInfo) -> Bool in
            let movieData = (movieInfo as? [String: AnyObject])!
            return (movieData["title"] as? NSString)!.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location != NSNotFound
        })
        searchActive = filteredSearch.count == 0 ? false: true
        moviesTableView.reloadData()
        moviesCollectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !filteredSearch.isEmpty ? filteredSearch.count: (self.moviesInfo?.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieCell = tableView.dequeueReusableCell(withIdentifier: "com.codepath.moviecell") as! MovieCell
        // select from search filtered or result movie array
        let currMoviesInfo = !filteredSearch.isEmpty ? filteredSearch: moviesInfo!
        let movieData = currMoviesInfo[indexPath.row] as? [String: AnyObject]
        movieCell.titleLabel.text = "\(movieData?["title"] as? String ?? "")"
        movieCell.overViewLabel.text = "\(movieData?["overview"] as? String ?? "")"

        movieCell.backgroundColor = UIColor(red:0.95, green:0.80, blue:0.10, alpha:1.0)
        movieCell.overViewLabel.backgroundColor = UIColor(red:0.95, green:0.80, blue:0.10, alpha:1.0)

        
        if let posterPath = movieData?["poster_path"] as? String {
            let posterBaseUrl = "https://image.tmdb.org/t/p/w500"
            loadPosterImage(posterUrlPath: posterBaseUrl + posterPath, posterView: movieCell.posterView)
            
        } else {
            // No poster image exists yet. Setting to default poster image
            movieCell.posterView.image = UIImage(named: "UnavailableImage")
        }
        
        // cell selection customization
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.85, green:0.6, blue:0.6, alpha:0.8)
        movieCell.selectedBackgroundView = backgroundView

        return movieCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesTableView.deselectRow(at:indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !filteredSearch.isEmpty ? filteredSearch.count: (self.moviesInfo?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.codepath.collectionviewmoviecell", for: indexPath) as! CollectionViewMovieCell

        // select from search filtered or result movie array
        let currMoviesInfo = !filteredSearch.isEmpty ? filteredSearch: moviesInfo!
        let movieData = currMoviesInfo[indexPath.row] as? [String: AnyObject]
        if let posterPath = movieData?["poster_path"] as? String {
            let posterBaseUrl = "https://image.tmdb.org/t/p/w500"
            loadPosterImage(posterUrlPath: posterBaseUrl + posterPath, posterView: movieCollectionViewCell.posterView)
            
        } else {
            // No poster image exists yet. Setting to default poster image
            movieCollectionViewCell.posterView.image = UIImage(named: "UnavailableImage")
        }
        
        // cell selection customization
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.85, green:0.6, blue:0.6, alpha:0.8)
        movieCollectionViewCell.selectedBackgroundView = backgroundView
        return movieCollectionViewCell
        
    }

    
    func loadPosterImage(posterUrlPath: String, posterView: AFNetworking.UIImageView) {
        let imageRequest = URLRequest(url: URL(string: posterUrlPath)!)
        
        posterView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    posterView.alpha = 0.0
                    posterView.image = image
                    UIView.animate(withDuration: 1, animations: { () -> Void in
                        posterView.alpha = 1.0
                    })
                } else {
                    posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                posterView.image = UIImage(named: "UnavailableImage")
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var indexPath: IndexPath?
        if (viewSelectorControl.selectedSegmentIndex == 0) {
            let movieCell = sender as! UITableViewCell
            indexPath = moviesTableView.indexPath(for: movieCell)
            
        } else {
            let movieCell = sender as! UICollectionViewCell
            indexPath = moviesCollectionView.indexPath(for: movieCell)
        }
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = !filteredSearch.isEmpty ? filteredSearch[indexPath!.row] : self.moviesInfo![indexPath!.row]

    }
   
}


