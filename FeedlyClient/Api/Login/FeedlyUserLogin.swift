
import Foundation

protocol FeedlyUserLogin {
    func userLoggedIn(userAccessTokenInfo: FeedlyUserAccessTokenInfo, userProfile: FeedlyUserProfile);
}