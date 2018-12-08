//
//  ProfileViewController.swift
//  Founders Directory
//
//  Created by Steve Liddle on 9/22/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//
//  See http://bit.ly/2da8gxb for discussion of this animation pattern
//

import UIKit

class ProfileViewController : UIViewController {
    
    // MARK: - Constants
    
    struct Animation {
        static let Duration = 0.2
    }

    struct Size {
        static let infoCellHeight: CGFloat = 132
        static let maxFontSize: CGFloat = 15
        static let minFontSize: CGFloat = 28
        static let maxHeaderHeight: CGFloat = 331
        static let minHeaderHeight: CGFloat = 198
        static let maxImageHeight: CGFloat = 80
        static let minImageHeight: CGFloat = 40
        static let maxImageOffset: CGFloat = 8
        static let minImageOffset: CGFloat = 4
        static let maxSubtitleHeight: CGFloat = 57
        static let minSubtitleHeight: CGFloat = 0
        // NEEDSWORK: calculate from profile text size; set high currently to test scrolling
        static let profileCellHeight: CGFloat = 400
        static let subtitleLineHeight: CGFloat = 19
    }
    
    struct Storyboard {
        static let infoCellIdentifier = "InfoCell"
        static let itemCellIdentifier = "ItemCell"
        static let profileCellIdentifier = "ProfileCell"
        static let selectableItemCellIdentifier = "SelectableItemCell"
    }

    struct Title {
        static let biography = "biography"
        static let cell = "mobile"
        static let email = "email"
        static let expertise = "expertise"
        static let home = "home"
        static let jobTitle = "title"
        static let linkedIn = "linked in"
        static let mailing = "mailing"
        static let organization = "organization"
        static let spouseCell = "spouse mobile"
        static let spouseEmail = "spouse email"
        static let website = "web site"
        static let work = "work"
    }

    struct UI {
        static let tintColor = UIColor(r: 109, g: 180, b: 77)
    }

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var callButton: CircleTagButton!
    @IBOutlet weak var emailButton: CircleTagButton!
    @IBOutlet weak var textButton: CircleTagButton!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var alternateView: UIView!

    // MARK: - Properties

    var founder: Founder?
    var maxHeaderHeight = Size.maxHeaderHeight
    var maxSubtitleHeight = Size.maxSubtitleHeight
    var minHeaderHeight = Size.minHeaderHeight
    var minSubtitleHeight = Size.minSubtitleHeight
    var previousScrollOffset: CGFloat = 0

    var founderModel = [(String, String, String)]()  // (Title, Action, CellIdentifier)
    var spouseModel = [(String, String, String)]()   // (Title, Action, CellIdentifier)

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem

        updateUI()

        AnalyticsHelper.shared.reportEvent(page: "view", url: "\(founder?.id ?? 0)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        imageView.applyCircleMask()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if founder != nil {
            navController()?.makeBarTransparent()

            headerHeightConstraint.constant = maxHeaderHeight
            updateHeader()

            if !alternateView.isHidden {
                alternateView.alpha = 0
                alternateView.isHidden = true
            }
        } else {
            alternateView.alpha = 1
            alternateView.isHidden = false
        }
    }

    private func navController() -> UINavigationController? {
        if let navVC = splitViewController?.viewControllers.first as? UINavigationController {
            // This is a little ugly.  And it's one of the reasons I told you in the hints on Slack
            // NOT to do a split view controller unless you're a real glutton for punishment.  It
            // all goes back to my decision to use a transparent nav bar for the profile page.  We
            // have to find the right nav bar to modify, and this logic covers the various cases on
            // the various device types.  *Sigh*  And I still don't have the tint change animating
            // smoothly -- it just pops.
            if splitViewController!.viewControllers.count <= 1 {
                if navigationController == nil
                    || navVC.topViewController is UINavigationController
                    || navVC.topViewController is FoundersViewController {
                    return navVC
                }
            }
        }

        return navigationController
    }

    override func viewWillDisappear(_ animated: Bool) {
        // NEEDSWORK: This isn't taking effect until after the bar animation has completed, so it
        // blinks in suddenly -- we should see if we can get this to animate properly.  For that
        // matter, the transition to clear (in viewWillAppear) also changes too suddenly.  This is
        // a bit tricky, because we have to tap into the layer animation for the navigation bar.
        navController()?.resetBarTransparency(UI.tintColor)

        super.viewWillDisappear(animated)

        if alternateView != nil && alternateView.isHidden {
            alternateView.isHidden = false
            alternateView.alpha = 1
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // NEEDSWORK: prepare for the edit-profile segue by telling the EditProfileViewController
        //            what the Founder record is that we want to edit
    }

    // MARK: - Helpers

    private func updateUI() {
        guard let founder = self.founder else {
            navigationItem.rightBarButtonItem = nil
            return
        }

        if founder.isPhoneListed {
            if !founder.cell.isEmpty {
                founderModel.append((Title.cell, founder.cell,
                                     Storyboard.selectableItemCellIdentifier))
            }

            if !founder.spouseCell.isEmpty {
                spouseModel.append((Title.cell, founder.spouseCell,
                                    Storyboard.selectableItemCellIdentifier))
            }
        }

        if founder.isEmailListed {
            if !founder.email.isEmpty {
                founderModel.append((Title.email, founder.email,
                                     Storyboard.selectableItemCellIdentifier))
            }

            if !founder.spouseEmail.isEmpty {
                spouseModel.append((Title.email, founder.spouseEmail,
                                    Storyboard.selectableItemCellIdentifier))
            }
        }

        if !founder.website.isEmpty {
            founderModel.append((Title.website, founder.website,
                                 Storyboard.selectableItemCellIdentifier))
        }

        if !founder.linkedIn.isEmpty {
            founderModel.append((Title.linkedIn, founder.linkedIn,
                                 Storyboard.selectableItemCellIdentifier))
        }

        if !founder.organizationName.isEmpty {
            founderModel.append((Title.organization, founder.organizationName,
                                 Storyboard.itemCellIdentifier))
        }

        if !founder.jobTitle.isEmpty {
            founderModel.append((Title.jobTitle, founder.jobTitle,
                                 Storyboard.itemCellIdentifier))
        }

        alternateView.isHidden = true

        imageView.image = PhotoManager.shared.getPhotoFor(founderId: founder.id)
        nameLabel.text = founder.fullName()

        var subtitleText = ""

        if founder.preferredFirstName.length > 0 {
            subtitleText = "“\(founder.preferredFirstName)”"
        } else {
            maxHeaderHeight -= Size.subtitleLineHeight
            maxSubtitleHeight -= Size.subtitleLineHeight
        }

        if let organizationLine = founder.organizationLine() {
            if subtitleText.length > 0 {
                subtitleText += "\n"
            }

            subtitleText += organizationLine
        } else {
            maxHeaderHeight -= Size.subtitleLineHeight
            maxSubtitleHeight -= Size.subtitleLineHeight
        }
        
        if let contactLine = founder.listedCellEmail() {
            if subtitleText.length > 0 {
                subtitleText += "\n"
            }
            
            subtitleText += contactLine
        } else {
            maxHeaderHeight -= Size.subtitleLineHeight
            maxSubtitleHeight -= Size.subtitleLineHeight
        }

        subtitleLabel.text = subtitleText

        callButton.disabled = !founder.isPhoneListed
        textButton.disabled = !founder.isPhoneListed
        emailButton.disabled = !founder.isEmailListed

        // NEEDSWORK: get the right decision for when to show/hide Edit button
        if founder.email != "drliddle@gmail.com" {
            navigationItem.rightBarButtonItem = nil
        }
    }

    // MARK: - Actions

    @IBAction func callPhone(_ sender: CircleTagButton) {
        guard let founder = self.founder else {
            return
        }
        
        if founder.isPhoneListed && founder.cell.length > 0 {
            if let url = URL(string: "tel://\(founder.cell)") {
                UIApplication.shared.open(url)
            }
        }
    }

    @IBAction func sendEmail(_ sender: CircleTagButton) {
        guard let founder = self.founder else {
            return
        }
        
        if founder.isEmailListed && founder.email.length > 0 {
            if let url = URL(string: "mailto://\(founder.email)") {
                UIApplication.shared.open(url)
            }
        }
    }

    @IBAction func sendText(_ sender: CircleTagButton) {
        guard let founder = self.founder else {
            return
        }
        
        if founder.isPhoneListed && founder.cell.length > 0 {
            if let url = URL(string: "sms://\(founder.cell)") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func cancelEdit(segue: UIStoryboardSegue) {
        // Ignore
    }

    @IBAction func saveEdit(segue: UIStoryboardSegue) {
        // NEEDSWORK: reload the edited Founder record
    }
}

// MARK: - Table view delegate

extension ProfileViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row \(indexPath.row)")
    }

    // MARK: - Scroll view delegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        var newHeight = headerHeightConstraint.constant

        if isScrollingDown {
            newHeight = max(Size.minHeaderHeight, headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(Size.maxHeaderHeight, headerHeightConstraint.constant + abs(scrollDiff))
        }

        if newHeight != headerHeightConstraint.constant {
            headerHeightConstraint.constant = newHeight
            updateHeader()
            setScrollPosition(position: previousScrollOffset)
        }

        previousScrollOffset = scrollView.contentOffset.y
    }

    func scrollViewDidStopScrolling() {
        let midPoint = minHeaderHeight + ((maxHeaderHeight - minHeaderHeight) / 2)

        if headerHeightConstraint.constant > midPoint {
            expandHeader()
        } else {
            collapseHeader()
        }
    }

    // MARK: - Helpers

    private func collapseHeader() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: Animation.Duration) {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        }
    }

    private func expandHeader() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: Animation.Duration) {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        }
    }

    private func setScrollPosition(position: CGFloat) {
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: position)
    }

    func updateHeader() {
        let range = maxHeaderHeight - minHeaderHeight
        let openAmount = headerHeightConstraint.constant - minHeaderHeight
        let percentage = openAmount / range

        imageHeightConstraint.constant = Size.minImageHeight + percentage * (Size.maxImageHeight - Size.minImageHeight)
//        imageOffsetConstraint.constant = Size.minImageOffset + percentage * (Size.maxImageOffset - Size.minImageOffset)
        subtitleHeightConstraint.constant = minSubtitleHeight + percentage * (maxSubtitleHeight - minSubtitleHeight)

        nameLabel.font = UIFont(name: ".SFUIDisplay", size: Size.maxFontSize - percentage * (Size.maxFontSize - Size.minFontSize))!
        subtitleLabel.alpha = percentage
    }
}

// MARK: - Table view data source

extension ProfileViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row <= 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.infoCellIdentifier, for: indexPath)

            if let infoCell = cell as? InfoCell {
                if founder?.spousePreferredFullName == "" {
                    infoCell.spouseNameIndicatorLabel.isHidden = true
                    infoCell.spouseNameLabel.isHidden = true
                } else {
                    infoCell.spouseNameIndicatorLabel.isHidden = false
                    infoCell.spouseNameLabel.isHidden = false
                    infoCell.spouseNameLabel.text = founder?.spousePreferredFullName ?? ""
                }
            }

            return cell
        } else if indexPath.row <= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.profileCellIdentifier, for: indexPath)

            if let profileCell = cell as? ProfileCell {
                profileCell.biographyLabel.text = founder?.biography.length ?? 0 > 0 ?
                    founder?.biography ?? "" :
                "This is not the Founder you're looking for.  You can go about your business.  Move along... move along."
            }

            return cell
        } else {
            var ix = indexPath.row - 2

            if ix < founderModel.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: founderModel[ix].2, for: indexPath)

                if let itemCell = cell as? ItemCell {
                    itemCell.titleLabel.text = founderModel[ix].0
                    itemCell.actionLabel.text = founderModel[ix].1
                } else if let selectableItemCell = cell as? SelectableItemCell {
                    selectableItemCell.titleLabel.text = founderModel[ix].0
                    selectableItemCell.actionLabel.text = founderModel[ix].1
                }
                
                return cell
            } else {
                ix -= founderModel.count

                let cell = tableView.dequeueReusableCell(withIdentifier: spouseModel[ix].2, for: indexPath)

                if let itemCell = cell as? ItemCell {
                    itemCell.titleLabel.text = spouseModel[ix].0
                    itemCell.actionLabel.text = spouseModel[ix].1
                } else if let selectableItemCell = cell as? SelectableItemCell {
                    selectableItemCell.titleLabel.text = spouseModel[ix].0
                    selectableItemCell.actionLabel.text = spouseModel[ix].1
                }

                return cell
            }
        }
    }

    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 0 {
            return Size.infoCellHeight
        } else if indexPath.row == 1 {
            return 400
        } else {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + founderModel.count + spouseModel.count
    }
}
