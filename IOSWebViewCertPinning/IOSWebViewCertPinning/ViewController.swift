import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var localHTTPSEndpoint = "https://localhost:4443" // secure server endpoint
    var bundledSslCert = "invalid_cert"
    var bundledSslCertExt = "der"
    
    
    @IBOutlet weak var webViewLoadHTTPS: WKWebView!
    @IBOutlet weak var textLocalHostEndpoint: UITextField!
    
    @IBOutlet weak var buttonReset: UIButton!
    @IBOutlet weak var textCert: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        webViewLoadHTTPS.navigationDelegate = self
        textCert.text = bundledSslCert
        textLocalHostEndpoint.text = localHTTPSEndpoint
        processResetClick(self)
    }
    
    @IBAction func processResetClick(_ sender: Any) {
        
        bundledSslCert = textCert.text!;
        localHTTPSEndpoint = textLocalHostEndpoint.text!
        
        webViewLoadHTTPS.loadHTMLString("<html><h2><p><a href='" + localHTTPSEndpoint + "'/>Go to localhost https </a></p></h2></html>", baseURL: nil);
        
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation){
        bundledSslCert = textCert.text!;
        localHTTPSEndpoint = textLocalHostEndpoint.text!
        print("didStartProvisionalNavigation")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("didReceive challenge")
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                if(errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: bundledSslCert, ofType: bundledSslCertExt)
                        
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        //Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Error 'didFail': \(error.localizedDescription)\nSchema: \(String(describing: webView.url?.absoluteString))")
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Error 'didFailProvisionalNavigation': \(error.localizedDescription)\nSchema: \(String(describing: webView.url?.absoluteString))")
    }
}
