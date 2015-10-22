import UIKit

struct Storage {

    private static let directoryPath = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory, .UserDomainMask, true)[0] 
    private static let levelsFolder: String = "levels/"
    private static let levelsPath =
    (directoryPath as NSString).stringByAppendingPathComponent(levelsFolder)

    private static let fileManager = NSFileManager.defaultManager()

    static func getSavedLevels() -> [String] {
        checkLevelsFolder()
        return (try! fileManager.contentsOfDirectoryAtPath(levelsPath))
            
    }

    static func getLevelData(fileName: String) -> [String:AnyObject]? {
        let filePath = (levelsPath as NSString).stringByAppendingPathComponent(fileName)
        if fileManager.fileExistsAtPath(filePath) {
            return NSDictionary(contentsOfFile: filePath) as! [String:AnyObject]?
        } else {
            return nil
        }
    }

    static func saveLevel(name: String, levelData: [String:AnyObject]) {
        checkLevelsFolder()
        let filePath = (levelsPath as NSString).stringByAppendingPathComponent(name)
        let data = try? NSPropertyListSerialization.dataWithPropertyList(levelData,
            format: NSPropertyListFormat.XMLFormat_v1_0, options: 0)
        data?.writeToFile(filePath, atomically: true)
    }

    private static func checkLevelsFolder() {
        if !fileManager.fileExistsAtPath(levelsFolder) {
            do {
                try fileManager.createDirectoryAtPath(levelsPath,
                    withIntermediateDirectories: false,
                    attributes: nil)
            } catch _ {
            }
        }
    }
}
