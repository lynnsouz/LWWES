import Foundation

struct ElementValue<ValueType: Hashable>: Hashable{
    let value: ValueType
    let timestamp: Date
    
    init(value: ValueType, timestamp: Date = Date()) {
        self.value = value
        self.timestamp = timestamp
    }
}

struct ElementDictionary<T, H> where T: Hashable, H: Hashable {
    private var items: Dictionary<T,ElementValue<H>> = [:]
    
    func find(_ key: T) -> Date? {
        return items[key]?.timestamp
    }
    
    mutating func add(key: T, value: H, with time: Date = Date()) {
        items[key] = ElementValue<H>(value: value, timestamp: time)
    }
    
    mutating func add(key: T, elementValue: ElementValue<H>) {
        items[key] = elementValue
    }
    
    mutating func remove(key: T, value: H, with time: Date = Date()) {
        guard let item = items[key]  else { return }
        if item.value == value && time == item.timestamp {
            items[key] = nil
        }
    }
    
    mutating private func mergeItems(_ new: Dictionary<T,ElementValue<H>>) {
        items = items.merging(new, uniquingKeysWith: {$0.timestamp > $1.timestamp ? $0 : $1})
    }
    
    mutating func merge(_ new: ElementDictionary<T, H>) {
        mergeItems(new.items)
    }
    
    func find(key: T) -> ElementValue<H>? {
        guard let item = items[key] else { return nil }
        return item
    }
    
    subscript(key: T) -> H? {
        get {
            guard let value = items[key] else { return nil }
            return value.value
        }
        
        set(newValue) {
            guard let newValue = newValue as? ElementValue<H> else { return }
            items[key] = newValue
        }
    }
}

let testTimes = (0...4).map { return Date(timeIntervalSinceNow: TimeInterval($0 * 60 * 60)) }


var testInsertRemoveSet = ElementDictionary<Int,String>()
for i in 0..<testTimes.count {
    testInsertRemoveSet.add(key: i, value: "\(i)", with: testTimes[i])
    assert(testInsertRemoveSet[i] == "\(i)", "Item just added")
}

assert(testInsertRemoveSet.find(testTimes.count) == nil, "Item not found")

for i in 0..<testTimes.count {
    testInsertRemoveSet.remove(key: i, value: "\(i)", with: testTimes[i])
    assert(testInsertRemoveSet[i] == nil, "Item just removed")
}


var testMergeSet = ElementDictionary<String,Int>()
var testMergeSet2 = ElementDictionary<String,Int>()

testMergeSet.add(key: "1", value: 1, with: testTimes[1])
testMergeSet2.add(key: "2", value: 2, with: testTimes[2])

testMergeSet.merge(testMergeSet2)
assert(testMergeSet["2"] == 2, "Items merged")
assert(testMergeSet2["1"] != 1, "Items not merged")


testMergeSet2.add(key: "1", value: 99, with: testTimes[2])
testMergeSet.merge(testMergeSet2)
assert(testMergeSet2["1"] == testMergeSet["1"], "Items merged and updated because its newer")
