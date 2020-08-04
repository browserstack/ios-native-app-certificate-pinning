# IOSWebViewCertPinning
Demo App for Self Signed SSL certificate validation for WebViews by Bundling and Pinning it within the iOS app

# Steps to setup the HTTPs self-signed server
1. Steps to start a self-signed HTTPs server: Check simple-https-server.py in the repo root directory
2. Convert the "valid_server_cert.pem" PEM server certificate to "valid_cert.der" DER formatted binary public certificate using the openssl command:
   openssl x509 -in valid_server_cert.pem -out valid_cert.der -outform DER
   
# Steps to configure the project (certificate bundling)
3. "Drag and Drop" the DER encoded binary formatted certificate for self signed HTTPs server on the “Products“ folder. This folder already contains the ".app" file. On the pop-up screen post “Drag and Drop“ is done, please click on “Add to Targets“ option. Overwrite the existing file.
4. Whether you are testing on emulators or on a cloud. platform like BrowserStack, follow the existing process required to build the app and test it.

# Testing the app
1. Provide the HTTPs localhost URL (https://localhost:4443 or https://bs-local.com:4443 for BrowserStack) and the certificate name (invalid_cert / valid_cert) in the respective app fields.
2. Click the Go button.

# Observations / Expected Results
1. The WKWebView does not show the server pages when presented with a invalid certificate.
2. The WKWebView shows the server pages when presented with a valid certificate. In case, the valid certificate is used once for the domain, it gets cached and even when presented with an invalid certificate thereafter, the webview shows the accurate server pages. In this case, use the Simulator app menu option > Device > Erase All Content and Settings, when testing on Simulators. For a BrowserStack session, just start a new session.

