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

import UIKit

class TodoCell : UITableViewCell {
	@IBOutlet var itemText: UILabel!
	@IBOutlet var isDoneButton: UIButton!
	var rowIndex:NSInteger!;
	var viewController:ViewController!
	var isDone:Bool!
		
	func loadItem(text text:String, isDone:Bool, rowIndex:NSInteger){
		self.itemText.text = text;
		self.rowIndex = rowIndex;
		self.isDone = isDone
		updateIsDoneImage()
	}
	
	@IBAction
	func onIsDoneClicked(){
		viewController.onIsDoneClicked(rowIndex: rowIndex)
	}
	
	private func updateIsDoneImage(){
		if (self.isDone == true){
			self.isDoneButton.setImage(UIImage(named: "checkbox1.png"), forState: UIControlState.Normal)
		} else{
			self.isDoneButton.setImage(UIImage(named: "checkbox2.png"), forState: UIControlState.Normal)
		}

	}

}