//
//  ViewController.swift
//  ToDoApp
//
//  Created by Fumiya Tanaka on 2020/04/30.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AppDomain

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let domain = AppDomain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource
    }
}

