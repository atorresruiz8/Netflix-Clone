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
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
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
        let alert = UIAlertController(title: "Downloading...", message: "Your selected movie will download to your device now.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
            self?.downloadPreviewTitle(with: (self?.viewModel)!)
        }))
        self.present(alert, animated: true)
    }
    
    @objc func playButtonPressed() {
        // present an alert to let the user know their movie is about to play
        let alert = UIAlertController(title: "Enjoy your movie!", message: "Your selected movie will begin playing now.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
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
        
        if downloadButton.isHidden {
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
    }
    
    func downloadPreviewTitle(with model: TitlePreviewViewModel) {
        // load the url to show a movie trailer or something related to the movie name
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else { return }
        webView.load(URLRequest(url: url))
        
        // search for titles with the name provided to us by model
        APICaller.shared.search(with: model.title, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    // if we found titles, then fill the titles array
                    self?.titles = titles
                    // since we are searching for an exact name of the movie/tv, then the title we want should be the first entry in the titles array
                    DataPersistenceManager.shared.downloadTitleWith(model: titles.first!, completion: { result in
                            switch result {
                            case .success(()):
                                // post a notification saying that we have downloaded this movie, so the DownloadsViewController can listen in and automatically update to show this new movie
                                NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
                            case .failure(let error):
                                // this was unsuccessful, print an error
                                print(error.localizedDescription)
                            } // end of switch result
                        }) // end of downloadTitleWith
                case .failure(let error):
                    print(error.localizedDescription)
                } // end of switch result
            } // end of DispatchQueue
        }) // end of APICaller
    }
}
