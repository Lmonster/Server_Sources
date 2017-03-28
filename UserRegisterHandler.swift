//
//  UserRegisterHandler.swift
//  MyServer
//
//  Created by lmonster on 28/03/2017.
//
//

import PerfectHTTP

enum RegisterError:Int, Error {
    case no = 0
    case paramentMiss = -1100
    case userExits = -1101
    case dataBaseQuery = -1102
}

class UserRegisterHandler {
    let REALNAME = "real_name"
    
    func handler(data:[String:Any]) -> RequestHandler {
        return {
            request,response in
            response.setHeader(.contentType, value: "application/json")
            var parament = [String:String]()
            var jsonData = [String:Int]()
            jsonData[Constant.CODE] = RegisterError.no.rawValue
            for (key,value) in request.postParams {
                parament[key] = value
            }
            
            guard parament.count > 4 else {
                jsonData[Constant.CODE] = RegisterError.paramentMiss.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard let _ = parament[Constant.USERNAME]?.characters.count ,
                  let _ = parament[Constant.PASSWORD]?.characters.count ,
                  let _ = parament[Constant.ROLL]?.characters.count ,
                  let _ = parament[Constant.REALNAME]?.characters.count,
                  let _ = parament[Constant.ID]?.characters.count else {
                    jsonData[Constant.CODE] = RegisterError.paramentMiss.rawValue
                    let _ = try? response.setBody(json: jsonData)
                    response.completed()
                    return
            }
            
            let roll = parament[Constant.ROLL] == "0" ? "stu" : "teacher"
            guard myDatabase.query(statement: "select * from reg_\(roll) where \(roll)_id=\"\(parament[Constant.ID]!)\"") else {
                jsonData[Constant.CODE] = RegisterError.dataBaseQuery.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            let result = myDatabase.storeResults()
            guard result?.numRows() == 0 else {
                jsonData[Constant.CODE] = RegisterError.userExits.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            
            guard myDatabase.query(statement: "insert into reg_\(roll)(\(roll)_id,name,password,real_name) values(\"\(parament[Constant.ID]!)\",\"\(parament[Constant.USERNAME]!)\",\"\(parament[Constant.PASSWORD]!)\",\"\(parament[Constant.REALNAME]!)\")") else {
                jsonData[Constant.CODE] = RegisterError.dataBaseQuery.rawValue
                let _ = try? response.setBody(json: jsonData)
                response.completed()
                return
            }
            jsonData[Constant.CODE] = RegisterError.no.rawValue
            let _ = try? response.setBody(json: jsonData)
            response.completed()
        }
    }
}
