# JumboPrivacy iOS App Code Test

Basic implementation of the requirements of the code challenge for Jumbo Privacy iOS team written by Manuel Gomez.

## Notes:
---
* The code includes a basic `ViewController` with a `UITableView` and a button to add new operations to the queue. TableView reloads the whole table on each add, but `insertRows(at:)` could be used to add them only to the end.
* Tapping on a cell starts the selected operation.
* The Operations Handler owns and controls the operations. It's implemented as a singleton for all operations on the same JavaScript script, which sent consisten messages as described in the challenge requirements.
* The cells get updated through a delegate from the `JumboOperation` objects.
* A ScriptProvider object was implemented to handle the download and creation of 
* Decided not to dequeue the tableView cells to ease the implementation.
* Things like error handling was not fully implemented in every function but there are very few force unwrappings, mostly URL's and calls to objects just after creation.
* Total time spent was around 10h. It wasn't the first time I worked with `WKWebView` but it was the first time I was injecting JavaScript and handling responses. Half of the time on this exercise was actually learning how to be able to get the responses from the script properly.
* Implemented a first version where the script was dynamically downloaded for each operation until realizing the requirements called for one shared instance of the JS script that handled many operations at the same time.