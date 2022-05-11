//
//  TitlePreviewViewModel.swift
//  Netflix
//
//  Created by Antonio Torres-Ruiz on 5/5/22.
//

import Foundation
struct TitlePreviewViewModel {
    let title: String
    let youtubeView: VideoElement
    let titleOverview: String
    
    func downloadPreviewTitle(with model: TitlePreviewViewModel) {
        // search for titles with the name provided to us by model
        APICaller.shared.search(with: model.title, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    // if we found titles, then fill the titles array
                    let titles: [Title] = titles
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
