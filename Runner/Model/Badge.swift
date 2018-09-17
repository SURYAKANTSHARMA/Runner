import Foundation
struct Badge {
  let name: String
  let imageName: String
  let information: String
  let distance: Double
  
  
  static let allBadges: [Badge] = {
    guard let fileURL = Bundle.main.url(forResource: "badges", withExtension: "txt") else {
      fatalError("No badges.txt file found")
    }
    do {
      let jsonData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
      let jsonResult = try JSONSerialization.jsonObject(with: jsonData) as! [[String: String]]
      return jsonResult.compactMap(Badge.init)
    } catch {
      fatalError("Cannot decode badges.txt")
    }
  }()

  
  init?(from dictionary: [String: String]) {
    guard
      let name = dictionary["name"],
      let imageName = dictionary["imageName"],
      let information = dictionary["information"],
      let distanceString = dictionary["distance"],
      let distance = Double(distanceString)
      else {
        return nil
    }
    self.name = name
    self.imageName = imageName
    self.information = information
    self.distance = distance
  }
}

extension Badge: Equatable {
  static func ==(lhs: Badge, rhs: Badge) -> Bool {
    return lhs.name == rhs.name
  }
}

