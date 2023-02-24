//
//  BeaconListCell.swift
//  BeaconSampleApp
//
//  Created by dongyeongkang on 2023/02/24.
//

import UIKit

class BeaconListCell: UITableViewCell {

    static let identifier: String = String(describing: BeaconListCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var macAddressLabel: UILabel!
    @IBOutlet weak var RSSILabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setData(name: String?, RSSI: Double, macAddress: String) {
        titleLabel.text = "Name: " + (name ?? "No name")
        macAddressLabel.text = macAddress
        RSSILabel.text = "RSSI: " + RSSI.description
        distanceLabel.text = "distance: " + rssiToDistance(rssi: RSSI)
    }
    
    private func rssiToDistance(rssi: Double) -> String {
        let n: Double = 2.0
        let alpha: Double = -63.0
        
        let distance = pow(10.0, ((alpha - rssi) / (10.0 * n)))
        let result = round((distance * 100.0)) / 100.0 // 소수점 두자리만 남겨놓고 나머지 버림.
        return result.description
    }
}
