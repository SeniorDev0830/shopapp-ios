//
//  AccountViewModel.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 12/6/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import RxSwift

class AccountViewModel: BaseViewModel {
    var policies = Variable<[Policy]>([Policy]())
    var customer = Variable<Customer?>(nil)
    
    private let customerUseCase = CustomerUseCase()
    private let loginStatusUseCase = LoginStatusUseCase()
    private let logoutUseCase = LogoutUseCase()
    private let shopUseCase = ShopUseCase()
    
    public func loadCustomer() {
        loginStatusUseCase.getLoginStatus { (isLoggedIn) in
            if isLoggedIn {
                getCustomer()
            }
        }
    }
    
    public func loadPolicies() {
        shopUseCase.getShop { [weak self] (shop) in
            self?.processResponse(with: shop)
        }
    }
    
    public func logout() {
        logoutUseCase.logout { [weak self] (isLoggedOut) in
            if isLoggedOut {
                self?.customer.value = nil
            }
        }
    }
    
    // MARK: - private
    private func getCustomer() {
        state.onNext(.loading(showHud: true))
        customerUseCase.getCustomer { [weak self] (customer, error) in
            if let error = error {
                self?.state.onNext(.error(error: error))
            }
            if let customer = customer {
                self?.customer.value = customer
                self?.state.onNext(.content)
            }
        }
    }
    
    private func processResponse(with shopItem: Shop) {
        var policiesItems = [Policy]()
        if let privacyPolicy = shopItem.privacyPolicy {
            policiesItems.append(privacyPolicy)
        }
        if let refundPolicy = shopItem.refundPolicy {
            policiesItems.append(refundPolicy)
        }
        if let termsOfService = shopItem.termsOfService {
            policiesItems.append(termsOfService)
        }
        policies.value = policiesItems
    }
}
