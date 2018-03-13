//
//  ArticleListViewModelSpec.swift
//  ShopAppTests
//
//  Created by Radyslav Krechet on 3/12/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Nimble
import Quick
import RxSwift

@testable import ShopApp

class ArticleListViewModelSpec: QuickSpec {
    override func spec() {
        let repository = ArticleRepositoryMock()
        let articleListUseCaseMock = ArticleListUseCaseMock(repository: repository)
        
        var viewModel: ArticleListViewModel!
        
        beforeEach {
            viewModel = ArticleListViewModel(articleListUseCase: articleListUseCaseMock)
        }
        
        describe("when view model initialized") {
            it("should have a correct superclass") {
                expect(viewModel).to(beAKindOf(BasePaginationViewModel.self))
            }
            
            it("should have variables with correct initial values") {
                expect(viewModel.items.value.isEmpty) == true
            }
        }
        
        describe("when first page loaded") {
            var disposeBag: DisposeBag!
            var states: [ViewState]!
            
            beforeEach {
                disposeBag = DisposeBag()
                states = []
                
                viewModel.state
                    .subscribe(onNext: { state in
                        states.append(state)
                    })
                    .disposed(by: disposeBag)
            }
            
            context("if not full page loaded") {
                it("should present loaded items") {
                    articleListUseCaseMock.isArticleCountLessThenConstant = true
                    articleListUseCaseMock.isNeedToReturnError = false
                    viewModel.reloadData()
                    
                    expect(viewModel.items.value.count) != kItemsPerPage
                    expect(viewModel.paginationValue).to(beNil())
                    expect(viewModel.canLoadMore) == false
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.content
                }
            }
            
            context("if full page loaded") {
                it("should present loaded items") {
                    articleListUseCaseMock.isArticleCountLessThenConstant = false
                    articleListUseCaseMock.isNeedToReturnError = false
                    viewModel.reloadData()
                    
                    expect(viewModel.items.value.count) == kItemsPerPage
                    expect(viewModel.paginationValue).to(beNil())
                    expect(viewModel.canLoadMore) == true
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.content
                }
            }
            
            context("if error did occured") {
                it("should not present items") {
                    articleListUseCaseMock.isNeedToReturnError = true
                    viewModel.reloadData()
                    
                    expect(viewModel.items.value.count) == 0
                    expect(viewModel.paginationValue).to(beNil())
                    expect(viewModel.canLoadMore) == false
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.error(error: nil)
                }
            }
        }
        
        describe("when next page loaded") {
            var disposeBag: DisposeBag!
            var states: [ViewState]!
            
            beforeEach {
                disposeBag = DisposeBag()
                states = []
            }
            
            context("if data loaded successfully") {
                it("should present loaded items") {
                    articleListUseCaseMock.isArticleCountLessThenConstant = false
                    articleListUseCaseMock.isNeedToReturnError = false
                    viewModel.reloadData()
                    
                    viewModel.state
                        .subscribe(onNext: { state in
                            states.append(state)
                        })
                        .disposed(by: disposeBag)
                    
                    viewModel.loadNextPage()
                    
                    expect(viewModel.items.value.count) == kItemsPerPage * 2
                    expect(viewModel.paginationValue as? String) == "pagination value"
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.content
                }
            }
            
            context("if error did occured") {
                it("should load first page and have error during loading next page") {
                    articleListUseCaseMock.isArticleCountLessThenConstant = false
                    articleListUseCaseMock.isNeedToReturnError = false
                    viewModel.reloadData()
                    
                    viewModel.state
                        .subscribe(onNext: { state in
                            states.append(state)
                        })
                        .disposed(by: disposeBag)
                    
                    articleListUseCaseMock.isNeedToReturnError = true
                    viewModel.loadNextPage()
                    
                    expect(viewModel.items.value.count) == kItemsPerPage
                    expect(viewModel.paginationValue as? String) == "pagination value"
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.error(error: nil)
                }
            }
        }
        
        describe("when try again pressed") {
            var disposeBag: DisposeBag!
            var states: [ViewState]!
            
            beforeEach {
                disposeBag = DisposeBag()
                states = []
                
                viewModel.state
                    .subscribe(onNext: { state in
                        states.append(state)
                    })
                    .disposed(by: disposeBag)
            }
            
            context("if data loaded successfully") {
                it("should present loaded items") {
                    articleListUseCaseMock.isArticleCountLessThenConstant = true
                    articleListUseCaseMock.isNeedToReturnError = false
                    viewModel.tryAgain()
                    
                    expect(viewModel.items.value.count) != kItemsPerPage
                    expect(viewModel.paginationValue).to(beNil())
                    expect(viewModel.canLoadMore) == false
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.content
                }
            }
            
            context("if error did occured") {
                it("should not present items") {
                    articleListUseCaseMock.isNeedToReturnError = true
                    
                    viewModel.tryAgain()
                    
                    expect(viewModel.items.value.count) == 0
                    expect(viewModel.paginationValue).to(beNil())
                    expect(viewModel.canLoadMore) == false
                    expect(states.count) == 2
                    expect(states.first) == ViewState.loading(showHud: true, isTranslucent: false)
                    expect(states.last) == ViewState.error(error: nil)
                }
            }
        }
    }
}
