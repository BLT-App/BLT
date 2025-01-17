//
//  ToDoItem.swift
//  BLT
//
//  Created by Jiahua Chen on 11/10/19.
//  Copyright © 2019 BLT App. All rights reserved.
//

import Foundation
import Datez
import RealmSwift

///A to-do item is an item representing a to-do in the list.
class ToDoItem: Object {

	/// The name of the class that the to-do is associated with.
	@objc dynamic var className: String = ""

	/// The title of the to-do.
	@objc dynamic var title: String = ""

	/// A description of the to-do and any resources/materials that are needed.
	@objc dynamic var assignmentDescription: String? = ""

	/// A due date fot the to-do.
	@objc dynamic var dueDate: Date = Date()

	/// Date of creation
	@objc dynamic var dateCreated: Date = Date()

	/// Date of Completion
	@objc dynamic var dateCompleted: Date?

    /// Identifier
    @objc dynamic var identifier: String = UUID().uuidString

	/// Time Spent In Focus Mode
	@objc dynamic var timeSpentInFocusMode: TimeInterval = 0
    
	/// Whether the to-do item is completed.
	@objc dynamic var completed: Bool = false

    /// Whether the to-do item has been deleted
    @objc dynamic var deleted: Bool = false
    
    /// List of every event referencing this item
    let referencingEvents: List<DatabaseEvent> = List<DatabaseEvent>()
    
    /// Initializes A New ToDoItem
    required init() {
        super.init()
    }
    
    /// Initializer With Values
    ///
    /// - Parameters:
    ///   - className: Name of class the task is for
    ///   - title: Name of the task
    ///   - description: Longer description of the task
    ///   - dueDate: Date task is due
    convenience init(className: String, title: String, description: String, dueDate: Date) {
        self.init()
        self.className = className
        self.title = title
        self.assignmentDescription = description
        self.dueDate = dueDate
        DispatchQueue.main.async {
            let realm = realmManager.realm
            if realm.isInWriteTransaction {
                let createdItemEvent = DatabaseEvent(event: .createdItem, item: self)
                self.referencingEvents.append(createdItemEvent)
            } else {
                do {
                    try realm.write {
                        let createdItemEvent = DatabaseEvent(event: .createdItem, item: self)
                        self.referencingEvents.append(createdItemEvent)
                    }
                } catch {
                    print("Error Occurred")
                }
                
            }
        }
        print("Task With Title: \(title) created")
    }
    
	/// Completes the current task.
	func completeTaskInListView() {
		if !completed {
			completed = true
			dateCompleted = dateManager.date
            let completionEvent = DatabaseEvent(event: .markedCompletedInListView, item: self)
            referencingEvents.append(completionEvent)
		}
	}
    
    /// Completes the current task.
    func completeTaskInFocusMode(duration: TimeInterval) {
        timeSpentInFocusMode += duration
        if !completed {
            completed = true
            dateCompleted = dateManager.date
            let completionEvent = DatabaseEvent(event: .markedCompletedInFocusMode, item: self, duration: duration)
            referencingEvents.append(completionEvent)
        }
    }

    /// undeletes a task
    func undoDeleteTask() {
        if deleted {
            deleted = false
        } else {
            print("Not Quite Sure How You Got Here...")
        }
    }
    
    /// Marks an item as deleted
    func markDeleted() {
        self.deleted = true
    }
    
    /**
     returns whether the function is deleted
     - Returns: the value of the deleted variable for the item
    */
    func isDeleted() -> Bool {
        return self.deleted
    }
    
	/// Uncompletes a task.
	func undoCompleteTask() {
        if completed {
            completed = false
            dateCompleted = nil
            let event = DatabaseEvent(event: .unmarkedComplete, item: self)
            referencingEvents.append(event)
        }
	}
    
	/// Checks whether a task is completed.
	///  - Returns: The state of completion of the item.
	func isCompleted() -> Bool {
		return completed
	}
    
    /// Returns the days between now and the due date.
    func getDueCounter() -> Int {
        let calendar = NSCalendar.current
        let dueDay = calendar.startOfDay(for: dueDate)
        let nowDay = calendar.startOfDay(for: dateManager.date)
        let inBetween = calendar.dateComponents([.day], from: nowDay, to: dueDay).day
        return inBetween!
    }
    
    /// Returns the due date as a relative time measure implemented in a string.
    func getDueString() -> String {
        if getDueCounter() == 0 {
            return "Due today"
        } else if getDueCounter() < 0 {
            return "Due \(abs(getDueCounter())) days ago"
        } else {
            return "Due in \(getDueCounter()) days"
        }
    }

	/// Marks an item as completed
	func markCompleted() -> Bool {
		self.completed = true
		return true
	}
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    /// Performs setup for studying in Focus Mode
    func startedStudyingInFocusMode() {
        let event = DatabaseEvent(event: .startedStudyingInFocusMode, item: self)
        referencingEvents.append(event)
    }
    
    /// Performs tear down after studying in Focus Mode
    ///
    /// - Parameter duration: Length of time spent in Focus Mode
    func stoppedStudyingInFocusMode(duration: TimeInterval) {
        timeSpentInFocusMode += duration
        let event = DatabaseEvent(event: .stoppedStudyingInFocusMode, item: self, duration: duration)
        referencingEvents.append(event)
    }
}
