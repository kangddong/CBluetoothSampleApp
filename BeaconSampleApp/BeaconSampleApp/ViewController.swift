//
//  ViewController.swift
//  BeaconSampleApp
//
//  Created by dongyeongkang on 2023/02/24.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UINib(nibName: BeaconListCell.identifier, bundle: nil),
                           forCellReuseIdentifier: BeaconListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Can'n find anything"
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    private var beaconList: [(peripheral: CBPeripheral, RSSI: Double, macAddress: String)] = []
    
    var centralManager : CBCentralManager!
    var serviceUUID = CBUUID(string: "FFE0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        initViews()
    }
    
    private func initNavigationItem() {
        let leftBarButton = UIBarButtonItem(title: "Stop",
                                            image: nil,
                                            target: self,
                                            action: #selector(stopScan))
        let rightBarButton = UIBarButtonItem(title: "Scan",
                                             image: nil,
                                             target: self,
                                             action: #selector(startScan))
        
        navigationItem.title = "Bluetooth Sample"
        navigationItem.setRightBarButton(rightBarButton, animated: true)
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
    }
    
    private func initViews() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        setConstraints()
    }
    
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])
    }
    
    @objc
    private func startScan() {
        guard centralManager.isScanning == false else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
        
        peripherals.forEach {
            print("===========================")
            print("name = \($0.name)")
            print("services = \($0.services)")
            print("identifier = \($0.identifier)")
            print("readRSSI() = \($0.readRSSI())")
            print("===========================")
        }
    }
    
    @objc
    private func stopScan() {
        centralManager.stopScan()
    }


}

// MARK: UITableViewDelegate, UITableViewDataSource Method
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyLabel.isHidden = beaconList.count == 0 ? false : true
        
        return beaconList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BeaconListCell.identifier, for: indexPath)
        guard let convertedCell = cell as? BeaconListCell else { return cell }
        let beacon = beaconList[indexPath.row]
        
        convertedCell.setData(name: beacon.peripheral.name,
                              RSSI: beacon.RSSI,
                              macAddress: beacon.macAddress)
        
        return convertedCell
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(#function)
        switch central.state {
            
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
        @unknown default:
            print("default")
        }
        guard central.state == .poweredOn else { return }
    }
    
    private func peripheralLog(_ peripheral: CBPeripheral, _ RSSI: NSNumber) {
        print(#function)
        print("============MBeacon===============")
        print("name = \(peripheral.name)")
        print("identifier = \(peripheral.identifier)")
        print("RSSI = \(RSSI)")
        print("===============MBeacon============")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name == "MBeacon" else { return }
        
        if let dic = advertisementData["kCBAdvDataServiceData"] as? Dictionary<CBUUID, Data>,
           let data = dic[CBUUID(string:"FFF1")],
           data.count == 11  {
            let macAddress = data[5...10]
            let strAddress = macAddress.map({ String(format:"%02x ", $0) })
                .joined()
                .uppercased()
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: " ", with: ":")
            
            
            
            guard beaconList.filter({ $2 == strAddress }).isEmpty  else { return }
            peripheralLog(peripheral, RSSI)
            beaconList.append((peripheral: peripheral, RSSI: RSSI.doubleValue, macAddress: strAddress))
            beaconList.sort { $0.RSSI < $1.RSSI}
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(#function)
        
        print("peripheral = \(peripheral)")
    }
}
