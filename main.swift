//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import MySQL
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

let port1 = 8080, port2 = 8181

let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"192.168.1.103",
			"port":port1,
			"routes":[
				["method":"post", "uri":"/api/stu/login", "handler":UserLoginHandler().handler],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"/Users/lmonster/www",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		],
		// Configuration data for another server which:
		//	* Redirects all traffic back to the first server.
		[
			"name":"localhost",
			"port":port2,
			"routes":[
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
				 "base":"http://localhost:\(port1)"]
			]
		]
	]
]

let myDatabase = MySQL()
if myDatabase.connect(host: "127.0.0.1", user: "lmonster", password: "iosdev,", db: "bilingual", port: 3306) {
    do {
        try HTTPServer.launch(configurationData: confData)
    } catch {
        fatalError("\(error)") // fatal error launching one of the servers
    }
}

