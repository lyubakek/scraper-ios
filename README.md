# A multi-threaded web scraper.

 
The App searches for a text inside a webpage and all it subpages.
The search starts from the given url. All the links that are found inside the given url are then used for the next search. It means that the App goes through a web graph by utilizing the Breadth First Search algorithm.
This search algorithm is also implemented in a concurrent way. Therefore, the App scans multiple urls at once.

## How to use the App:

 1. Fill in the following fields:
   - A start url
   - A maximum number of concurrent searches
   - A text to search inside urls
   - A total number of searched urls
2. Press Start button

You can press the Stop button, if you want to immediately finish scanning pages.

##### Technologies and algorithms used:
- UIKit: UIView, UITextField, UITableView
- Architecture pattern: MVP
- Concurrency: GCD, Operation, NSLock
- Algorithms and data structures: queue, BFS

![2014-10-22 11_35_09](https://thumbs.gfycat.com/ElderlyCreamyFinch-size_restricted.gif)
