/*
* Copyright 2016 IBM Corp.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import SwiftyJSON

class TodoItem{
	var id:NSInteger
	var text:String
	var isDone:Bool
	
	init(id:NSInteger, text:String, isDone:Bool){
		self.id = id
		self.text = text
		self.isDone = isDone
	}
	
	static func fromJson(json:JSON) -> TodoItem {
		let itemId = json["id"].intValue
		let itemText = json["text"].stringValue
		let itemIsDone = json["isDone"].boolValue
		return TodoItem(id:itemId, text:itemText, isDone:itemIsDone)
	}
	
	func toJson() -> JSON!{
		let dict = ["id":id, "text":text, "isDone":isDone]
		let json = JSON(dict)
		return json
	}
	

}
