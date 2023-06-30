//
//  NetworkView.swift
//  Timebound
//
//  Created by Ananay Arora on 6/29/23.
//


import SwiftUI
import SystemConfiguration.CaptiveNetwork
import Network

struct NetworkView: View {
    @State private var isPinging = false
    @State private var pingResult = ""
    @State private var ipAddress = ""
    @State private var isConnectedViaWiFi = false
    @State private var urlInput = ""
    @State private var networkLog: [String] = []
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Network Information")) {
                    Text("Public IP Address: \(ipAddress)")
                    Text("Connection: \(isConnectedViaWiFi ? "Wi-Fi" : "Cellular")")
                }
                
                Section(header: Text("HTTP Request")) {
                    TextField("URL", text: $urlInput)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    Button(action: {
                        makeRequest()
                    }) {
                        Text("Make Request")
                    }
                    .disabled(urlInput.isEmpty || isPinging)
                }
                
                Section(header: Text("Ping Network")) {
                    Button(action: {
                        ping()
                    }) {
                        Text(isPinging ? "Pinging Network..." : "Ping Network")
                    }
                    .disabled(isPinging)
                }
                
                if (networkLog.count > 0) {
                    Section(header: Text("Network Logs")) {
                        ForEach(networkLog, id: \.self) { logItem in
                            Text(logItem)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchIPAddress()
            checkConnection()
        }
    }
    
    func nlog(text: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "[MM/dd/yy HH:mm:ss]:"
        let timestamp = formatter.string(from: Date())
        let logEntry = "\(timestamp) \(text)"
        networkLog.insert(logEntry, at: 0)
    }

    
    func fetchIPAddress() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://api.ipify.org/")!) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            if let ipAddress = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.ipAddress = ipAddress
                }
            }
        }
        task.resume()
    }
    
    func checkConnection() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnectedViaWiFi = path.usesInterfaceType(.wifi)
            }
        }
    }
    
    func ping() {
        guard let url = URL(string: "https://www.apple.com") else {
            return
        }
        
        isPinging = true
        pingResult = ""
        
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                nlog(text: error == nil ? "Ping successful" : "Ping failed: " + (error?.localizedDescription ?? "Unknown Error"))
                self.isPinging = false
            }
        }
        
        task.resume()
    }
    
    func makeRequest() {
        guard let url = URL(string: urlInput) else {
            return
        }
        
        isPinging = true
        pingResult = ""
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    nlog(text: "Request failed: \(error.localizedDescription)")
                } else {
                    nlog(text: "Request successful to: \(url.absoluteString)")
                    nlog(text: response.debugDescription)
                }
                self.isPinging = false
            }
        }
        
        task.resume()
    }
}

