//
//  BaseViewController.swift
//  Lockdown
//
//  Copyright © 2019 Confirmed Inc. All rights reserved.
//

import UIKit
import MessageUI
import CocoaLumberjackSwift
import PopupDialog

open class BaseViewController: UIViewController, MFMailComposeViewControllerDelegate {

    let interactionBlockViewTag = 84814
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // disable swipe down to dismiss
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(emailTeam))
//        longPressRecognizer.minimumPressDuration = 4
//        self.view.addGestureRecognizer(longPressRecognizer)
        
        //        let doubleLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(signoutUser))
        //        doubleLongPressRecognizer.minimumPressDuration = 5
        //        doubleLongPressRecognizer.numberOfTouchesRequired = 2
        //        self.view.addGestureRecognizer(doubleLongPressRecognizer)
    }
    
    // MARK: - AwesomeSpotlight Helper
    
    func getRectForView(_ v: UIView) -> CGRect {
        if let sv = v.superview {
            return sv.convert(v.frame, to: self.view)
        }
        return CGRect.zero;
    }
    
    // MARK: - Handle NSURLError and APIErrors
    
    func popupErrorAsNSURLError(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            self.showPopupDialog(title: "Network Error", message: "Please check your internet connection. If this persists, please contact team@lockdownhq.com.\n\nError Description\n\(nsError.localizedDescription)", acceptButton: "Okay")
            return true
        }
        else {
            return false
        }
    }
    
    func popupErrorAsApiError(_ error: Error) -> Bool {
        if let e = error as? ApiError {
            self.showPopupDialog(title: "Error Code \(e.code)", message: "\(e.message)\n\n If this persists, please contact team@lockdownhq.com.", acceptButton: "Okay")
            return true
        }
        else {
            return false
        }
    }
    
    func showWhyTrustPopup() {
        let popup = PopupDialog(
            title: "Why Trust Lockdown?",
            message: "Lockdown is open source and fully transparent, which means anyone can see exactly what it's doing. Also, Lockdown Firewall has a simple, strict Privacy Policy, while Lockdown VPN is fully audited by security experts.",
            image: UIImage(named: "whyTrustImage")!,
            buttonAlignment: .vertical,
            transitionStyle: .bounceDown,
            preferredWidth: 300.0,
            tapGestureDismissal: true,
            panGestureDismissal: false,
            hideStatusBar: true,
            completion: nil)
        
        let privacyPolicyButton = DefaultButton(title: "Privacy Policy", dismissOnTap: true) {
            self.showPrivacyPolicyModal()
        }
        
        let auditReportsButton = DefaultButton(title: "Audit Reports", dismissOnTap: true) {
            self.showAuditModal()
        }
        
        let pressButton = DefaultButton(title: "Press & Media", dismissOnTap: true) {
            self.showWebsitePressModal()
        }
        
        let okayButton = CancelButton(title: "Done", dismissOnTap: true) {  }
        popup.addButtons([privacyPolicyButton, auditReportsButton, pressButton, okayButton])
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func showVPNDetails() {
        let popup = PopupDialog(
            title: "About Lockdown VPN",
            message: "Lockdown VPN is powered by Confirmed VPN, the open source, no-logs, and fully audited VPN.",
            buttonAlignment: .vertical,
            transitionStyle: .bounceDown,
            preferredWidth: 300.0,
            tapGestureDismissal: true,
            panGestureDismissal: false,
            hideStatusBar: true,
            completion: nil)
        
        let whyUseVPNButton = DefaultButton(title: "Why Use VPN?", dismissOnTap: true) {
            self.showModalWebView(title: "Why VPN?", urlString: "https://confirmedvpn.com/why-vpn")
        }
        
        let auditReportsButton = DefaultButton(title: "Audit Reports", dismissOnTap: true) {
            self.showAuditModal()
        }
        
        let confirmedWebsiteButton = DefaultButton(title: "Confirmed Site", dismissOnTap: true) {
            self.showModalWebView(title: "Why VPN?", urlString: "https://confirmedvpn.com")
        }
        
        let okayButton = CancelButton(title: "Done", dismissOnTap: true) {  }
        popup.addButtons([whyUseVPNButton, auditReportsButton, confirmedWebsiteButton, okayButton])
        
        self.present(popup, animated: true, completion: nil)
    }
    
    // MARK: - WebView
    
    func showPrivacyPolicyModal() {
        self.showModalWebView(title: "Privacy Policy", urlString: "https://lockdownhq.com/privacy")
    }
    
    func showTermsModal() {
        self.showModalWebView(title: "Terms", urlString: "https://lockdownhq.com/terms")
    }
    
    func showWebsiteModal() {
        self.showModalWebView(title: "Website", urlString: "https://lockdownhq.com")
    }
    
    func showWebsitePressModal() {
        self.showModalWebView(title: "Press & Media", urlString: "https://lockdownhq.com/#press")
    }
    
    func showAuditModal() {
        self.showModalWebView(title: "Audit Reports", urlString: "https://openlyoperated.org/report/confirmedvpn")
    }
    
    func showModalWebView(title: String, urlString: String) {
        if let url = URL(string: urlString) {
            let storyboardToUse = storyboard != nil ? storyboard! : UIStoryboard(name: "Main", bundle: nil)
            if let webViewVC = storyboardToUse.instantiateViewController(withIdentifier: "webview") as? WebViewViewController {
                webViewVC.titleLabelText = title
                webViewVC.url = url
                self.present(webViewVC, animated: true, completion: nil)
            }
            else {
                DDLogError("Unable to instantiate webview VC")
            }
        }
        else {
            DDLogError("Invalid URL \(urlString)")
        }
    }
    
    // MARK: - Block user interactions during transactions
    
    func unblockUserInteraction() {
        let view = self.view.viewWithTag(interactionBlockViewTag)
        if view != nil {
            view?.removeFromSuperview()
        }
    }
    
    func blockUserInteraction() {
        let view = UIView(frame: self.view.frame)
        view.tag = interactionBlockViewTag
        view.backgroundColor = UIColor.init(white: 1.0, alpha: 0.0)
        self.view.addSubview(view)
    }

    // MARK: - Popup Helper
    
    func showPopupDialog(title: String, message: String, acceptButton: String, completionHandler: @escaping () -> () = {}) {
        let popup = PopupDialog(title: title.uppercased(), message: message, image: nil, transitionStyle: .bounceDown, hideStatusBar: false)
        
        let acceptButton = DefaultButton(title: "OK", dismissOnTap: true) { completionHandler() }
        popup.addButtons([acceptButton])
        
        self.present(popup, animated: true, completion: nil)
    }
    
//    func showPopupDialogSubmitError(title : String = "Sorry, An Error Occurred", message : String, error: Error?) {
//        let popup = PopupDialog(title: title, message: message, image: nil, transitionStyle: .zoomIn, hideStatusBar: false)
//        let acceptButton = DefaultButton(title: "Don't Submit", dismissOnTap: true) { }
//        let submitButton = DefaultButton(title: "Submit", dismissOnTap: true) {
//            self.emailTeam(messageBody: "Hey Lockdown Team, \nI encountered a bug while using Lockdown, and I'm reporting it here. \n (To the user: just tap Send at the top right to submit the bug report -- no need to do anything else and we'll get back to you ASAP.", messageErrorBody: error ? error! || "")
//        }
//        popup.addButtons([acceptButton, submitButton])
//        self.present(popup, animated: true, completion: nil)
//    }
    
    // MARK: - Email Team
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func emailTeam(messageBody: String = "Hey Lockdown team, \nI have a question, issue, or suggestion - ", messageErrorBody: String = "") {
        DDLogInfo("")
        DDLogInfo("UserId: \(keychain[kVPNCredentialsId] ?? "No User ID")")
        DDLogInfo("UserReceipt: \(keychain[kVPNCredentialsKeyBase64] ?? "No User Receipt")")
        
        if (Client.hasValidCookie()) {
            DDLogInfo("Has loaded cookie.")
        }
        DDLogInfo("")
        
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["team@lockdownhq.com"])
            composeVC.setSubject("Lockdown Feedback (iOS)")
            var message = messageBody
            if messageErrorBody != "" {
                message = messageBody + "\n\nError Details: " + messageErrorBody
            }
            composeVC.setMessageBody(message, isHTML: false)
            let attachmentData = NSMutableData()
            for logFileData in logFileDataArray {
                attachmentData.append(logFileData as Data)
            }
            composeVC.addAttachmentData(attachmentData as Data, mimeType: "text/plain", fileName: "ConfirmedLogs.log")
            self.present(composeVC, animated: true, completion: nil)
        } else {
            showPopupDialog(title: "Couldn't Find Your Email Client",
                            message: "Please make sure you have added an e-mail account to your iOS device and try again.", acceptButton: "OK")
        }
    }
    
    //    @objc func signoutUser() {
    //        // TODO: complete this debug functionality
    //        let title = "CLEAR RECEIPT DATA?"
    //        let message = "Would you like to clear your local receipts?"
    //
    //        let popup = PopupDialog(title: title, message: message, image: nil, buttonAlignment: .horizontal)
    //
    //        let acceptButton = DefaultButton(title: "YES", dismissOnTap: true) {
    //           // Auth.clearCookies()
    //           // Auth.signoutUser()
    //        }
    //        let cancelButton = DefaultButton(title: "CANCEL", dismissOnTap: true) { }
    //        popup.addButtons([cancelButton, acceptButton])
    //
    //        self.present(popup, animated: true, completion: nil)
    //    }
    
}
