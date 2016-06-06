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
import BMSCore
import BMSAnalyticsAPI
import SwiftSpinner

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	let logger = Logger.logger(forName: "asd")
	
	@IBOutlet
	var tableView: UITableView!
	
	var todoItems:[TodoItem] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let cellNib = UINib(nibName: "TodoCell", bundle: nil);
		tableView.registerNib(cellNib, forCellReuseIdentifier: "TodoCell")
		
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = UIColor.clearColor()
		refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	override func viewDidAppear(animated: Bool) {
		becomeFirstResponder()
		loadItems()
	}
	
	func loadItems(){
		logger.debug("loadingItems")
		SwiftSpinner.show("Loading items...", animated: true)
		TodoFacade.getItems({ (items:[TodoItem]?, error:NSError?) in
			SwiftSpinner.hide(){
				if let err = error{
					self.showError(err.localizedDescription)
				} else {
					self.todoItems = items!;
					self.dispatchOnMainQueueAfterDelay(0) {
						self.tableView.reloadData()
					}
				}
			}
		})
	}
	
	@IBAction
	func onAddNewItemClicked(){
		logger.debug("onAddNewItemClicked")
		let alert = UIAlertController(title: "Add new todo", message: "Enter todo text", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
			textField.placeholder = "Todo text"
			textField.secureTextEntry = false
			textField.text = ""
		})
		
		alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler:{ (action:UIAlertAction) -> Void in
			let itemText = alert.textFields![0].text! as String
			let todoItem = TodoItem(id: 0, text: itemText, isDone: false)
			SwiftSpinner.show("Loading items...", animated: true)
			TodoFacade.addNewItem(todoItem, completionHandler: {(error:NSError?) in
				if let err = error{
					SwiftSpinner.hide(){
						self.showError(err.localizedDescription)
					}
				} else {
					self.loadItems()
				}
			})
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:{ (action:UIAlertAction) -> Void in
		}))
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	// onEditItemClicked
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		logger.debug("onEditItemClicked " + indexPath.row.description)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		let clickedTodoItem = todoItems[indexPath.row]
		
		let alert = UIAlertController(title: "Edit todo item", message: "Enter todo text", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
			textField.placeholder = "Todo text"
			textField.secureTextEntry = false
			textField.text = clickedTodoItem.text
		})
		
		alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler:{ (action:UIAlertAction) -> Void in
			let itemText = alert.textFields![0].text! as String
			let todoItem = TodoItem(id: clickedTodoItem.id, text: itemText, isDone: clickedTodoItem.isDone)
			SwiftSpinner.show("Loading items...", animated: true)
			TodoFacade.updateItem(todoItem, completionHandler: {(error:NSError?) in
				if let err = error{
					SwiftSpinner.hide(){
						self.showError(err.localizedDescription)
					}
				} else {
					self.loadItems()
				}
			})
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:{ (action:UIAlertAction) -> Void in
		}))
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	@IBAction
	func onTodoItemLongPressed(sender:UILongPressGestureRecognizer){
		if (sender.state == UIGestureRecognizerState.Began){
			let todoCell = sender.view as! TodoCell
			onDeleteClicked(rowIndex: todoCell.rowIndex)
		}
		
	}
	
	func onDeleteClicked(rowIndex rowIndex:NSInteger){
		print("onDeleteClicked :: " + rowIndex.description)
		let clickedTodoItem = todoItems[rowIndex]
		
		let alert = UIAlertController(title: "Delete todo item", message: "Would you like to delete this todo?", preferredStyle: UIAlertControllerStyle.Alert)
		
		alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler:{ (action:UIAlertAction) -> Void in
			SwiftSpinner.show("Loading items...", animated: true)
			TodoFacade.deleteItem(clickedTodoItem.id, completionHandler: {(error:NSError?) in
				if let err = error{
					SwiftSpinner.hide(){
						self.showError(err.localizedDescription)
					}
				} else {
					self.loadItems()
				}
			})
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:{ (action:UIAlertAction) -> Void in
		}))
		self.presentViewController(alert, animated: true, completion: nil)
		
		
	}
	
	func onIsDoneClicked(rowIndex rowIndex:NSInteger){
		logger.debug("isDoneClicked :: " + rowIndex.description)
		SwiftSpinner.show("Loading items...", animated: true)
		let todoItem:TodoItem = todoItems[rowIndex]
		todoItem.isDone = !todoItem.isDone
		TodoFacade.updateItem(todoItem, completionHandler: { (error:NSError?) in
			if let err = error{
				SwiftSpinner.hide(){
					self.showError(err.localizedDescription)
				}
			} else {
				self.loadItems()
			}
		})
	}
	
	
	func handleRefresh(refreshControl:UIRefreshControl){
		self.logger.debug("handleRefresh")
		self.loadItems()
		refreshControl.endRefreshing()
	}
	
	func showError(errText:String){
		dispatchOnMainQueueAfterDelay(0) {
			SwiftSpinner.show(errText, animated: false)
		}
		
		dispatchOnMainQueueAfterDelay(3) {
			SwiftSpinner.hide()
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.todoItems.count;
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: TodoCell;
		cell = self.tableView.dequeueReusableCellWithIdentifier("TodoCell") as! TodoCell
		cell.viewController = self;
		let todoItem = todoItems[indexPath.row]
		cell.loadItem(text: todoItem.text, isDone: todoItem.isDone, rowIndex: indexPath.row)
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onTodoItemLongPressed))
		cell.addGestureRecognizer(longPressGestureRecognizer)
		
		return cell
	}
	
	func dispatchOnMainQueueAfterDelay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))+100
			),
			dispatch_get_main_queue(), closure)
	}
	
}
