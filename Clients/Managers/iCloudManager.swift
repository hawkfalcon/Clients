import Foundation

class iCloudManager {
    static var documentsURL: NSURL!

    class func setup() {
        guard let iCloudDocumentsURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)?
        .URLByAppendingPathComponent("Documents") else {
            print("Unable to get iCloud URL")
            return
        }
        documentsURL = iCloudDocumentsURL
        if (!NSFileManager.defaultManager().fileExistsAtPath(iCloudDocumentsURL.path!, isDirectory: nil)) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
    }

    class func backupClientData(clients: [Client], type: String) -> NSURL {
        if documentsURL == nil { return NSURL() }
        let content = CSVManager.getCSV(clients, type: type)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let date = formatter.stringFromDate(NSDate())
        let file = documentsURL.URLByAppendingPathComponent("\(type)_\(date).csv");
        do {
            try content.writeToURL(file, atomically: false, encoding: NSUTF8StringEncoding);
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return file
    }
}
