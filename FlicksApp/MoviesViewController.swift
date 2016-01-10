//
//  MoviesViewController.swift
//  FlicksApp
//
//  Created by Corey Salzer on 1/10/16.
//  Copyright © 2016 Corey Salzer. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    var movies: [NSDictionary]?
    
     var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delay(15, closure: {
            self.apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8edX"
            
            self.delay(15, closure: {
                self.apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            })
        })
        
        networkErrorView.superview?.bringSubviewToFront(networkErrorView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        EZLoadingActivity.show("Loading...", disableUI: true)
        getMovies()
    }
    
    func getMovies() {
        //var apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8edX"

        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            if responseDictionary["results"] == nil {
                                self.networkErrorView.hidden = false
                                EZLoadingActivity.hide(success: false, animated: true)
                            }
                            else {
                                self.tableView.reloadData()
                                self.networkErrorView.hidden = true
                                EZLoadingActivity.hide(success: true, animated: true)
                            }
                            
                            
                    }
                }
        });
        task.resume()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        getMovies()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        if movies != nil {
            let movie = movies![indexPath.row]
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            let posterPath = movie["poster_path"] as! String
            
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            //cell.posterView.setImageWithURL(imageUrl!)
            
            cell.posterView.setImageWithURLRequest(NSURLRequest(URL: imageUrl!), placeholderImage: nil, success: { (request, response, image) in
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                
                    // Image fade in
                    UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            cell.posterView.alpha = 1.0
                        }, completion: nil)


                }, failure: nil)

        }
    
        return cell
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
