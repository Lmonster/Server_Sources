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
 *  pwd:xxx,
 *  role:0/1 (0教师，1学生)
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
    let ROLL = "roll"
    
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
            
            guard paraments.keys.count > 2 else {
                jsonData[self.CODE] = LoginError.ParamentMissError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard paraments.keys.contains(self.USERNAME) &&
                  paraments.keys.contains(self.PASSWORD) &&
                  paraments.keys.contains(self.ROLL) else {
                jsonData[self.CODE] = LoginError.ParamentMissError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard let _ = paraments[self.USERNAME]?.characters.count,
                  let _ = paraments[self.PASSWORD]?.characters.count,
                  let _ = paraments[self.ROLL]?.characters.count
            else {
                jsonData[self.CODE] = LoginError.ParamentMissError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            let tableName = paraments[self.ROLL] == "0" ? "reg_stu" : "reg_teacher"
            if !myDatabase.query(statement: "select name,password from \(tableName) where name=\"\(paraments[self.USERNAME]!)\" and password=\"\(paraments[self.PASSWORD]!)\"") {
                jsonData[self.CODE] = LoginError.DataBaseQueryError.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            } else {
                guard let result = myDatabase.storeResults() else {
                    jsonData[self.CODE] = LoginError.DataBaseQueryError.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
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
            }
        }
    }
}
