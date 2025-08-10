import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    private var progressView = UIProgressView(progressViewStyle: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ChatGPT"
        setupWebView()
        setupToolbar()
        loadChatGPT()
    }

    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        // Progress
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .clear
        navigationItem.titleView = progressView
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    func setupToolbar() {
        let safari = UIBarButtonItem(title: "Open in Safari", style: .plain, target: self, action: #selector(openInSafari))
        navigationItem.rightBarButtonItem = safari
    }

    @objc func refreshWebView() {
        webView.reload()
        webView.scrollView.refreshControl?.endRefreshing()
    }

    @objc func openInSafari() {
        guard let url = webView.url else { return }
        UIApplication.shared.open(url)
    }

    func loadChatGPT() {
        if let url = URL(string: "https://chat.openai.com/") {
            webView.load(URLRequest(url: url))
        }
    }

    // KVO for progress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            // hide when complete with smooth animation
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut) {
                    self.progressView.alpha = 0
                } completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                }
            } else {
                progressView.alpha = 1
            }
        }
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}
