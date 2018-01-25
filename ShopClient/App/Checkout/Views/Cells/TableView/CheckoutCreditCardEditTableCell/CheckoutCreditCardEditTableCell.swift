//
//  CheckoutPaymentEditTableCell.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 1/3/18.
//  Copyright © 2018 Evgeniy Antonov. All rights reserved.
//

import UIKit

protocol CheckoutCreditCardEditTableCellProtocol: class {
    func didTapEditCard()
}

class CheckoutCreditCardEditTableCell: UITableViewCell {
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var holderNameLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    
    weak var delegate: CheckoutCreditCardEditTableCellProtocol?
    
    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        editButton?.setTitle("Button.Edit".localizable.uppercased(), for: .normal)
    }
    
    // MARK: - Public
    
    public func configure(with creditCard: CreditCard) {
        cardNumberLabel.text = creditCard.maskedNumber
        expirationDateLabel.text = creditCard.expirationDateLocalized
        holderNameLabel.text = creditCard.holderName
    }
    
    // MARK: - Actions
    
    @IBAction func editTapped(_ sender: UIButton) {
        delegate?.didTapEditCard()
    }
}
