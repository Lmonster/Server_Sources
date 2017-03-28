//
//  DataBase.swift
//  MyServer
//
//  Created by lmonster on 28/03/2017.
//
//

import MySQL

class DataBase {
    
    private static var sql = MySQL()
    static func shared() -> MySQL {
        return self.sql
    }
}
