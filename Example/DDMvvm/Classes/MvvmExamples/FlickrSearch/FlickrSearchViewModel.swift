//
//  FlickrSearchViewModel.swift
//  DDMvvm_Example
//
//  Created by ToanDK on 8/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Action
import DDMvvm

class FlickrSearchPageViewModel: ListViewModel<MenuModel, FlickrImageCellViewModel> {
    
    // Alert service injection
    let alertService: IAlertService = DependencyManager.shared.getService()
    let flickrService: FlickrService = DependencyManager.shared.getService()
    
    let rxSearchText = BehaviorRelay<String?>(value: nil)
    let rxIsSearching = BehaviorRelay<Bool>(value: false)
    let rxIsLoadingMore = BehaviorRelay<Bool>(value: false)
    
    var page = 1
    let perPage = 20
    var finishedSearching = false
    
    var tmpBag: DisposeBag?
    
    lazy var loadMoreAction: Action<Void, Void> = {
        return Action() { .just(self.loadMore()) }
    }()
    
    override func react() {
        // Whenever text changed
        rxSearchText
            .do(onNext: { text in
                self.tmpBag = nil // stop current load more if any
                self.page = 1 // reset to page 1
                self.finishedSearching = false // reset done state
                
                if !text.isNilOrEmpty {
                    self.rxIsSearching.accept(true)
                }
            })
            .debounce(.milliseconds(500), scheduler: Scheduler.shared.mainScheduler)
            .subscribe(onNext: { [weak self] text in
                if !text.isNilOrEmpty {
                    self?.doSearch(keyword: text!)
                }
            }) => disposeBag
    }
    
    private func doSearch(keyword: String, isLoadMore: Bool = false) {
        let bag = isLoadMore ? tmpBag : disposeBag
        flickrService.search(keyword: keyword, page: self.page)
            .map(prepareSources)
            .subscribe(onSuccess: { [weak self] cvms in
                self?.itemsSource.reset([cvms])
                self?.rxIsSearching.accept(false)
            }, onError: { [weak self] error in
                self?.rxIsLoadingMore.accept(false)
            }) => bag
    }
    
    private func loadMore() {
        if itemsSource.countElements() <= 0 || finishedSearching || rxIsLoadingMore.value { return }
        
        tmpBag = DisposeBag()
        
        rxIsLoadingMore.accept(true)
        page += 1
        
        doSearch(keyword: rxSearchText.value!, isLoadMore: true)
    }
    
    private func prepareSources(_ response: FlickrSearchResponse) -> [FlickrImageCellViewModel] {
        if response.stat == .fail {
            alertService.presentOkayAlert(title: "Error", message: "\(response.message)\nPlease be sure to provide your own API key from Flickr.")
        }
        
        if response.page >= response.pages {
            finishedSearching = true
        }
        
        return response.photos.toCellViewModels() as [FlickrImageCellViewModel]
    }
}
