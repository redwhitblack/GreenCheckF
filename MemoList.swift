//
//  MemoList.swift
//  GreencheckF
//

import Foundation

class MemoList {
    var items: [String] = []

    func addMemo(_ memo: String) {
        items.append(memo)
    }
}
