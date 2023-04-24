//
//  ViewController.swift
//  webSocket_basic_tutorial
//
//  Created by 김라영 on 2023/04/21.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    enum SocketAction: Int {
        //소켓 연결 - tag = 0
        //소켓 끊기 - tag = 1
        //메시지 보내기 - tag = 2
        case connect = 0
        case disconnect = 1
        case sendMsg = 2
    }
    var websocketTask: URLSessionWebSocketTask? = nil
    
    @IBOutlet weak var dodgePriceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        connectSocket()
    }
    
    fileprivate func disConnect() {
        websocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    fileprivate func connectSocket() {
        disConnect()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: "wss://ws.dogechain.info/inv") else {
            return
        }
        websocketTask = session.webSocketTask(with: url)
        
        websocketTask?.resume()
        
        receiveMsg()
    }
    
    fileprivate func receiveMsg() {
        websocketTask?.receive(completionHandler: { [weak self] (result: Result<URLSessionWebSocketTask.Message, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(.data(let msg)):
                print(#fileID, #function, #line, "- success(.data) msg: \(msg)")
            case .success(.string(let msg)):
                print(#fileID, #function, #line, "- success(.string) msg: \(msg)")
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SocketResponse.self, from: Data(msg.utf8))
                    DispatchQueue.main.async {
                        self.dodgePriceLabel.text = result.msg?.value ?? "0"
                    }
                    
                } catch {
                    print(#fileID, #function, #line, "- err: \(error.localizedDescription)")
                }
                
                self.receiveMsg()
            case .success(let msg):
                print(#fileID, #function, #line, "- just success msg: \(msg)")
            case .failure(let failure):
                print(#fileID, #function, #line, "- failure: \(failure)")
            }
            
        })
    }
    
    fileprivate func sendMessage() {
        print(#fileID, #function, #line, "- sendMessage")
//        "{\"op\":\"price_sub\"}"
        let dictionary = ["op": "price_sub"]
        guard let jsonString = JSON(dictionary).rawString() else { return }
        print(#fileID, #function, #line, "- jsonString: \(jsonString)")
        
        let messageToSend = URLSessionWebSocketTask.Message.string(jsonString)
        self.websocketTask?.send(messageToSend, completionHandler: { err in
            print(#fileID, #function, #line, "- err: \(err)")
        })
        
    }
    
    @IBAction func handleBtnAction(_ sender: UIButton) {
        //소켓 연결 - tag = 0
        //소켓 끊기 - tag = 1
        //메시지 보내기 - tag = 2
        print(#fileID, #function, #line, "- sender: \(sender.tag)")
        let socketAction = SocketAction(rawValue: sender.tag)
        
        switch socketAction {
        case .connect:
            connectSocket()
        case .disconnect:
            disConnect()
        case .sendMsg:
            sendMessage()
        case .none:
            print(#fileID, #function, #line, "- none")
        }
    }
    
}

extension ViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print(#fileID, #function, #line, "- 연결됨, session: \(session)")
    }

    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print(#fileID, #function, #line, "- 끊김, session: \(session), closeCode: \(closeCode), reason: \(reason)")
    }
}

