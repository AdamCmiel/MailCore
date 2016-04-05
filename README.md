# MailCore Email App

Submission for Udacity iOS Nanodegree Final Project #5

## User Interface

The app consists of two View Controllers, one for the inbox, and one for the email detail view.
The InboxVC, [`ViewController`](MailCore/ViewController.swift) consists of a navigation bar with a logout
button and the title _Inbox_, and a UITableView of the emails fetched.


On app load and logout, the app will present a modal View Controller to login with google OAuth.
On successful login, the app downloads several of the users recent emails, and displays them in the tableView.


On _logout_, the app data will be flushed, and the user will be prompted to log in again.


When a tableViewCell is selected in the inbox, the mail detail VC, [`WebViewViewController`](MailCore/WebViewViewController.swift)
will be presented, and will load the email html in a UIWebView, for the user to consume.


## Data Persistence

Fetching email is a relatively small, but non-trivial data fetching operation, so the app seeks to minimize the download
requirements by caching the data as such:

- Emails will be stored in CoreData with their `uid`, `subject`, and a pointer to a location on disk where to store the html
- Email html content will be saved to a file in the app's Documents directory.  Email can be fetched on cold app start by reading from the disk store


## Out of Scope

What this app does not do

- Report back to the gmail IMAP server that emails have been read, or reflagged otherwise
- Send email
- Support multiple logins
- Support other email providers
- Make you coffee
- Take out the dog


## Installation

this build requires [cocoapods](https://cocoapods.org/) to get all frameworks from google, github


In your terminal, after cloning, execute the following
```sh
pod install
```

Then open the `.xcworkspace` in Xcode, build and run.


## Testing

Not part of the product requirement


