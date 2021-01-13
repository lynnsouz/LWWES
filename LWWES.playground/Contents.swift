import Foundation


struct Element<T: Hashable> {
    private var dateDictionary = [T: Date]()
    
    func find(_ key: T) -> Date? {
        return dateDictionary[key]
    }
    
    mutating func add(_ item: T, with time: Date = Date()) {
        if let previousAddTime = find(item), previousAddTime >= time {
            return
        }
        dateDictionary[item] = time
    }
}

struct ElementSet<T: Hashable> {
    private var addSet = Element<T>()
    private var removeSet = Element<T>()
    
    func find(_ key: T) -> Date? {
        guard let add = addSet.find(key) else { return nil }
        guard let remove = removeSet.find(key) else { return add }
        
        if (add > remove) {
            return add
        }
        return nil
    }
    
    mutating func add(_ item: T, with time: Date = Date()) {
        addSet.add(item, with: time)
    }
    
    mutating func remove(_ item: T, with time: Date = Date()) {
        guard find(item) != nil else { return }
        removeSet.add(item, with: time)
    }
}


var testSet = ElementSet<Int>()
let testTimes = (0...4).map { return Date(timeIntervalSinceNow: TimeInterval($0 * 60 * 60)) }

for i in 0..<testTimes.count {
    testSet.add(i, with: testTimes[i])
    assert(testSet.find(i) == testTimes[i], "Item just added")
}

assert(testSet.find(testTimes.count) == nil, "Item not found")
