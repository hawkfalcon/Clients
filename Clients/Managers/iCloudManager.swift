import Foundation

class iCloudManager {
    static var documentsURL: URL!

    class func setup() {
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
        .appendingPathComponent("Documents") else {
            print("Unable to get iCloud URL")
            return
        }
        documentsURL = iCloudDocumentsURL
        if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
            do {
                try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

    }

    class func backupClientData(_ clients: [Client], type: String) -> URL {
        if documentsURL == nil {
            return URL(fileURLWithPath: "")
        }
        let content = CSVManager.getCSV(clients, type: type)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let date = formatter.string(from: Date())
        let file = documentsURL.appendingPathComponent("\(type)_\(date).csv")
        do {
            try content.write(to: file, atomically: false, encoding: String.Encoding.utf8.rawValue)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return file
    }
}
