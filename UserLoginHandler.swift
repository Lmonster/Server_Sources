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
    case no = 0
    case paramentMiss = -1000
    case userNotExits = -1001
    case dataBaseConnect = -1002
    case dataBaseQuery = -1003
}

class UserLoginHandler {
    
    func handler(data:[String:Any]) throws -> RequestHandler {
        return {
            request,response in
            var jsonData = [Constant.CODE:LoginError.no.rawValue]
            response.setHeader(.contentType, value: "application/json")
            response.setHeader(.accessControlAllowOrigin, value: "*")
            let postedInfo = request.postParams
            var paraments = [String:String]()
            for (key,value) in postedInfo {
                paraments[key] = value
            }
            
            guard paraments.keys.count > 2 else {
                jsonData[Constant.CODE] = LoginError.paramentMiss.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard let _ = paraments[Constant.ID]?.characters.count,
                  let _ = paraments[Constant.PASSWORD]?.characters.count,
                  let _ = paraments[Constant.ROLL]?.characters.count
            else {
                jsonData[Constant.CODE] = LoginError.paramentMiss.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            let roll = paraments[Constant.ROLL] == "0" ? "stu" : "teacher"
            if !myDatabase.query(statement: "select name,password from reg_\(roll) where \(roll)_id=\"\(paraments[Constant.ID]!)\" and password=\"\(paraments[Constant.PASSWORD]!)\"") {
                jsonData[Constant.CODE] = LoginError.dataBaseQuery.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            } else {
                guard let result = myDatabase.storeResults() else {
                    jsonData[Constant.CODE] = LoginError.dataBaseQuery.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                    return
                }
                if result.numRows() > 0 {
                    jsonData[Constant.CODE] = LoginError.no.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                } else {
                    jsonData[Constant.CODE] = LoginError.userNotExits.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                }
            }
        }
    }
}
