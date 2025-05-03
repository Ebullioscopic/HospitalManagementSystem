//
//  NgrokCertificateDelegate.swift
//  Hospitality
//
//  Created by admin44 on 28/04/25.
//


import Foundation

extension URLSession {
    static var ngrokSession: URLSession {
        let configuration = URLSessionConfiguration.default
        let delegate = NgrokCertificateDelegate()
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

class NgrokCertificateDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, 
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // For ngrok domains, accept the certificate
        if challenge.protectionSpace.host.contains("ngrok") {
            print("Accepting certificate for ngrok domain")
            if let serverTrust = challenge.protectionSpace.serverTrust {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        } else {
            // Standard handling for other domains
            completionHandler(.performDefaultHandling, nil)
        }
    }
}