import UIKit

struct Storage {

    private static let directoryPath = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory, .UserDomainMask, true)[0] as String
    private static let levelsFolder: String = "levels/"
    private static let levelsPath =
    directoryPath.stringByAppendingPathComponent(levelsFolder)

    private static let fileManager = NSFileManager.defaultManager()

    static func getSavedLevels() -> [String] {
        checkLevelsFolder()
        return fileManager.contentsOfDirectoryAtPath(levelsPath, error: nil)
            as [String]
    }

    static func getLevelData(fileName: String) -> [String:AnyObject]? {
        let filePath = levelsPath.stringByAppendingPathComponent(fileName)
        if fileManager.fileExistsAtPath(filePath) {
            return NSDictionary(contentsOfFile: filePath) as [String:AnyObject]?
        } else {
            return nil
        }
    }

    static func saveLevel(name: String, levelData: [String:AnyObject]) {
        checkLevelsFolder()
        var filePath = levelsPath.stringByAppendingPathComponent(name)
        let data = NSPropertyListSerialization.dataWithPropertyList(levelData,
            format: NSPropertyListFormat.XMLFormat_v1_0, options: 0, error: nil)
        data?.writeToFile(filePath, atomically: true)
    }

    private static func checkLevelsFolder() {
        if !fileManager.fileExistsAtPath(levelsFolder) {
            fileManager.createDirectoryAtPath(levelsPath,
                withIntermediateDirectories: false,
                attributes: nil, error: nil)
        }
    }
}
