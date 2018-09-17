import Foundation
struct BadgeStatus {
  let badge: Badge
  let earned: Run?
  let silver: Run?
  let gold: Run?
  let best: Run?
  
  static let silverMultiplier = 1.05
  static let goldMultiplier = 1.1
  
  
  static func badgesEarned(runs: [Run]) -> [BadgeStatus] {
    return Badge.allBadges.map { badge in
      var earned: Run?
      var silver: Run?
      var gold: Run?
      var best: Run?
      
      for run in runs where run.distance > badge.distance {
        if earned == nil {
          earned = run
        }
        
        let earnedSpeed = earned!.distance / Double(earned!.duration)
        let runSpeed = run.distance / Double(run.duration)
        
        if silver == nil && runSpeed > earnedSpeed * silverMultiplier {
          silver = run
        }
        
        if gold == nil && runSpeed > earnedSpeed * goldMultiplier {
          gold = run
        }
        
        if let existingBest = best {
          let bestSpeed = existingBest.distance / Double(existingBest.duration)
          if runSpeed > bestSpeed {
            best = run
          }
        } else {
          best = run
        }
      }
      
      return BadgeStatus(badge: badge, earned: earned, silver: silver, gold: gold, best: best)
    }
  }

  
}
