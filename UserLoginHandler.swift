//
//  UserLoginHandler.swift
//  MyServer
//
//  Created by lmonster on 28/03/2017.
//
//

import MySQL
import PerfectHTTP

/*
 * path: login
 *
 * parament: 
 * {
 *  uName:xxx,
 *  pwd:xxx
 * }
 *
 * return:
 * {
 *   code:0/-1,
 * }
 *
 */
enum LoginError:Int, Error {
    case NoError = 0
    case ParamentMissError = -1000
    case ParamentNotMatchError = -1001
    case UserNotExits = -1002
    case DataBaseConnectError = -1003
    case DataBaseQueryError = -1004
}

class UserLoginHandler {
    let USERNAME = "uName"
    let PASSWORD = "pwd"
    let CODE = "code"
    let STATUS = "status"
    
    func handler(data:[String:Any]) throws -> RequestHandler {
        return {
            request,response in
            var jsonData = [self.CODE:LoginError.NoError.rawValue]
            response.setHeader(.contentType, value: "application/json")
            let postedInfo = request.postParams
            var paraments = [String:String]()
            for (key,value) in postedInfo {
                paraments[key] = value
            }
            
            // check data
            guard paraments.keys.count > 1 else {
                jsonData[self.CODE] = LoginError.ParamentMissError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard paraments.keys.contains(self.USERNAME) &&
                  paraments.keys.contains(self.PASSWORD) else {
                jsonData[self.CODE] = LoginError.ParamentMissError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard let _ = paraments[self.USERNAME]?.characters.count,
                  let _ = paraments[self.PASSWORD]?.characters.count
            else {
                jsonData[self.CODE] = LoginError.ParamentMissError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            let sql = DataBase.shared()
            guard sql.connect(host: "127.0.0.1", user: "lmonster", password: "iosdev,", db: "bilingual", port: 3306) else {
                jsonData[self.CODE] = LoginError.DataBaseConnectError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            if !sql.query(statement: "select name,password from reg_stu where name=\"\(paraments[self.USERNAME]!)\" and password=\"\(paraments[self.PASSWORD]!)\"") {
                jsonData[self.CODE] = LoginError.DataBaseQueryError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                sql.close()
                return
            } else {
                guard let result = sql.storeResults() else {
                    jsonData[self.CODE] = LoginError.DataBaseQueryError.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                    sql.close()
                    return
                }
                if result.numRows() > 0 {
                    jsonData[self.CODE] = LoginError.NoError.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                } else {
                    jsonData[self.CODE] = LoginError.UserNotExits.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                }
                sql.close()
            }
        }
    }
}
