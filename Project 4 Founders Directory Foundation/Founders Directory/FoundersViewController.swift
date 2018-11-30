//
//  FoundersViewController.swift
//  Founders Directory
//
//  Created by Steve Liddle on 9/21/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit
import GRDB

class FoundersViewController : UITableViewController {
    
    // MARK: - Constants

    private struct Storyboard {
        static let cellIdentifier = "FounderCell"
        static let cornerRadius: CGFloat = 30
        static let logInIdentifier = "Log In"
        static let setPasswordIdentifier = "Set Password"
        static let viewSegueIdentifier = "ViewProfile"
    }

    private struct Request {
        static let foundersByName = Founder.order(Column(Founder.Field.preferredFullName))
    }

    // MARK: - Properties

    var foundersController: FetchedRecordsController<Founder>!

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let controller = try? FetchedRecordsController(FounderDatabase.shared.dbQueue,
                                                                  request: Request.foundersByName) {
            self.foundersController = controller

            controller.trackChanges(
                willChange: { [unowned self] _ in
                    self.tableView.beginUpdates()
                },
                onChange: { [unowned self] (controller, record, change) in
                    switch change {
                    case .insertion(let indexPath):
                        self.tableView.insertRows(at: [indexPath], with: .fade)
                        
                    case .deletion(let indexPath):
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    case .update(let indexPath, _):
                        if let cell = self.tableView.cellForRow(at: indexPath) {
                            self.configure(cell, at: indexPath)
                        }

                    case .move(let indexPath, let newIndexPath, _):
                        let cell = self.tableView.cellForRow(at: indexPath)
                        self.tableView.moveRow(at: indexPath, to: newIndexPath)

                        if let cell = cell {
                            self.configure(cell, at: newIndexPath)
                        }
                    }
                },
                didChange: { [unowned self] _ in
                    self.tableView.endUpdates()
            })

            try? controller.performFetch()
        }

        AnalyticsHelper.shared.reportEvent(page: "list")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changesMade),
                                               name: ApiHelper.Notice.changesMade,
                                               object: nil)

        if !ApiHelper.shared.isLoggedIn() {
            presentLoginViewController(animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Respond to synchronization changes

    @objc func changesMade(notification: Notification) {
        var id = 0

        if let idString = notification.userInfo?[ApiHelper.Key.userId] as? String {
            id = Int(idString) ?? id
        }

        DispatchQueue.main.async() { [weak self] in
            if let visiblePaths = self?.tableView.indexPathsForVisibleRows {
                if id > 0 {
                    for path in visiblePaths {
                        if let founder = self?.foundersController.record(at: path) {
                            if founder.id == id {
                                self?.tableView.reloadRows(at: [path], with: .automatic)
                                break
                            }
                        }
                    }
                } else {
                    self?.tableView.reloadRows(at: visiblePaths, with: .automatic)
                }
            } else {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.viewSegueIdentifier {
            if let navVC = segue.destination as? UINavigationController {
                if let destVC = navVC.topViewController as? ProfileViewController {
                    destVC.founder = foundersController.record(at: tableView.indexPathForSelectedRow!)
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func cancel(segue: UIStoryboardSegue) {
        // Do nothing
    }

    @IBAction func showActionMenu(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Change Password", style: .default) {
            [weak self] (alertAction) in
                self?.performSegue(withIdentifier: Storyboard.setPasswordIdentifier, sender: sender)
            })
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive) {
            (alertAction) in
            ApiHelper.shared.logout()

            if let founderApp = UIApplication.shared.delegate as? AppDelegate {
                founderApp.displayLoginScene()
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = sender

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let founder = foundersController.record(at: indexPath)

        if let founderCell = cell as? FounderCell {
            founderCell.founderNameLabel?.text = founder.preferredFullName
            founderCell.founderCompanyLabel?.text = founder.organizationName

            if let imageView = founderCell.founderImageView {
                DispatchQueue.global().async {
                    if let photoImage = PhotoManager.shared.getPhotoFor(founderId: founder.id) {
                        DispatchQueue.main.async {
                            imageView.image = photoImage
                        }
                    } else {
                        DispatchQueue.main.async {
                            imageView.image = UIImage(named: "defaultPhoto-60")
                        }
                    }
                }

                imageView.layer.cornerRadius = Storyboard.cornerRadius
                imageView.layer.masksToBounds = true
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdentifier, for: indexPath)

        configure(cell, at: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundersController.sections[section].numberOfRecords
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return foundersController.sections.count
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.viewSegueIdentifier, sender: indexPath)
    }

    // MARK: - Private helpers

    private func presentLoginViewController(animated: Bool) {
        performSegue(withIdentifier: Storyboard.logInIdentifier, sender: animated ? self : nil)
    }
}
