//
//  ViewController.swift
//  AblyTVTest
//
//  Created by Ricardo Pereira on 13/12/2018.
//  Copyright © 2018 Ably. All rights reserved.
//

import UIKit
import Ably

class ViewController: UIViewController {

    let dataAdapter1 = MessagesDataAdapter()
    let dataAdapter2 = MessagesDataAdapter()

    var realtime1: ARTRealtime!
    var channel1: ARTRealtimeChannel!

    var realtime2: ARTRealtime!
    var channel2: ARTRealtimeChannel!

    let channelName = "tv"
    let appKey = <key>

    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var sendButton1: UIButton!

    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var sendButton2: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let options = ARTClientOptions(key: appKey)
        options.logLevel = .debug

        realtime1 = ARTRealtime(options: options)
        realtime2 = ARTRealtime(options: options)

        channel1 = realtime1.channels.get(channelName)
        channel2 = realtime2.channels.get(channelName)

        tableView1.delegate = dataAdapter1
        tableView1.dataSource = dataAdapter1
        tableView1.register(UITableViewCell.self, forCellReuseIdentifier: "Message")

        tableView2.delegate = dataAdapter2
        tableView2.dataSource = dataAdapter2
        tableView2.register(UITableViewCell.self, forCellReuseIdentifier: "Message")

        textField1.text = ""
        textField1.placeholder = "data"

        textField2.text = ""
        textField2.placeholder = "data"

        channel1.subscribe("client1") { [weak self] message in
            self?.dataAdapter1.messages.append(message.data as! String)
            self?.tableView1.reloadData()
        }

        channel1.subscribe("client2") { [weak self] message in
            self?.dataAdapter2.messages.append(message.data as! String)
            self?.tableView2.reloadData()
        }
    }

    @IBAction func handleSend1(_ sender: Any) {
        let message = textField1.text
        textField1.text = ""
        channel1.publish("client2", data: message) { error in
            print("Publish", error ?? "nil")
        }
    }

    @IBAction func handleSend2(_ sender: Any) {
        let message = textField2.text
        textField2.text = ""
        channel2.publish("client1", data: message) { error in
            print("Publish", error ?? "nil")
        }
    }

}

class MessagesDataAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {

    var messages: [String] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }

}
