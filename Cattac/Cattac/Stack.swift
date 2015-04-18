/*
    The Stack data structure
*/

struct Stack<T> {
    
    private var items: [T] = [T]()
    
    mutating func push(item: T) {
        items.append(item)
    }
    
    mutating func pop() -> T? {
        if isEmpty {
            return nil
        } else {
            let poppedItem: T = items.removeAtIndex(count - 1)
            return poppedItem
        }
    }
    
    func peek() -> T? {
        if isEmpty {
            return nil
        } else {
            return items[count - 1]
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
            for var index = count - 1; index >= 0; index-- {
                let itemToAdd: T? = items[index]
                arrayToReturn.append(itemToAdd!)
            }
            
            return arrayToReturn
        }
    }
}