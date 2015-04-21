
private let _dateUtilsSharedInstance: DateUtils = DateUtils()

class DateUtils {
    
    private var _dateFormatter: NSDateFormatter?
    
    private init() {
    }
    
    class var instance: DateUtils {
        return _dateUtilsSharedInstance
    }
    
    class var dateFormatter: NSDateFormatter {
        if instance._dateFormatter == nil {
            instance._dateFormatter = NSDateFormatter()
            instance._dateFormatter!.dateFormat = "MM-dd-yyyy HH:mm"
        }
        
        return instance._dateFormatter!
    }
    
    class func isMinutesBeforeNow(time: NSDate, minutes: Int) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let comps = NSDateComponents()
        comps.minute = minutes
        
        let refDate = calendar.dateByAddingComponents(comps,
            toDate: time, options: NSCalendarOptions.allZeros)
        return isAfter(refDate!, dateTwo: NSDate())
    }
    
    class func isAfter(dateOne: NSDate, dateTwo: NSDate) -> Bool {
        return dateOne.compare(dateTwo) == NSComparisonResult.OrderedAscending
    }
    
    class func nowString() -> String {
        return dateFormatter.stringFromDate(NSDate())
    }
}
