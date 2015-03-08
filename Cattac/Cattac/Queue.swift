/*
    The Queue data structure
*/

struct Queue<T> {
    private var items: [T] = [T]()
    
    mutating func enqueue(item: T) {
        items.append(item)
    }
    
    mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return items.removeAtIndex(0)
        }
    }
    
    func peek() -> T? {
        if isEmpty {
            return nil
        } else {
            return items.first
        }
    }
    
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    mutating func removeAll() {
        items.removeAll(keepCapacity: false)
    }
    
    func toArray() -> [T] {
        var arrayToReturn: [T] = [T]()
        
        if isEmpty {
            return arrayToReturn
        } else {
            for itemToAdd in items {
                arrayToReturn.append(itemToAdd)
            }
            
            return arrayToReturn
        }
    }
}