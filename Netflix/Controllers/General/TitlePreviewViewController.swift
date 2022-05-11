//
//  TitlePreviewViewController.swift
//  Netflix
//
//  Created by Antonio Torres-Ruiz on 5/5/22.
//

import UIKit
import WebKit

class TitlePreviewViewController: UIViewController {
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var titles: [Title] = [Title]()
    private var viewModel: TitlePreviewViewModel?
    private var selectedTitle: Title?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.text = "Test"
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "This is a thing"
        return label
    }()
    
    internal lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(previewDownloadButtonPressed), for: .touchUpInside)
        return button
    }()
    
    internal lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(previewDownloadButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(downloadButton)
        
        if downloadButton.isHidden { view.addSubview(playButton) }
        
        view.backgroundColor = .systemBackground
        configureConstraints()
    }
    
    @objc func previewDownloadButtonPressed() {
        // present an alert to let the user know their movie is downloading
        APICaller.shared.search(with: viewModel!.title, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    self?.titles = titles
                    self?.selectedTitle = titles.first!
                    var alert = UIAlertController()
                    let selectedTitleName = self?.selectedTitle?.original_title ?? self?.selectedTitle?.original_name ?? "Unknown"
                    if (self!.downloadButton.isHidden) {
                        alert = UIAlertController(title: "Enjoy your movie!", message: "\(selectedTitleName) will begin playing now.", preferredStyle: .alert)
                    } else {
                        alert = UIAlertController(title: "Downloading...", message: "\(selectedTitleName) will download to your device now.", preferredStyle: .alert)
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                        self?.viewModel?.downloadPreviewTitle(with: (self?.viewModel!)!)
                    }))
                    self?.present(alert, animated: true)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
    }
    
    func configureConstraints() {
        let webViewConstraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 350)
        ]
        
        let titleLabelConstaints = [
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let overviewLabelConstraints = [
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let downloadButtonConstraints = [
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            downloadButton.widthAnchor.constraint(equalToConstant: 140),
            downloadButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        let playButtonConstraints = [
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            playButton.widthAnchor.constraint(equalToConstant: 140),
            playButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstaints)
        NSLayoutConstraint.activate(overviewLabelConstraints)
        
        if downloadButton.isHidden { // constrain the play button instead if the download button is hidden
            NSLayoutConstraint.activate(playButtonConstraints)
        } else {
            NSLayoutConstraint.activate(downloadButtonConstraints)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func configureTitlePreview(with model: TitlePreviewViewModel) {
        // update the global viewModel variable with the information passed in from HomeViewController so we can use it for downloading movies off TitlePreviewViewController
        viewModel = model
        titleLabel.text = model.title
        titleLabel.numberOfLines = 0
        overviewLabel.text = model.titleOverview
        
        // load the url to show a movie trailer or something related to the movie name
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else { return }
        webView.load(URLRequest(url: url))
    }
}
