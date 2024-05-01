import Foundation
import Combine
import UIKit

protocol BackendControllerFeed {
    func getFeed(page: Int, perPage: Int) -> AnyPublisher<FeedPage, Error>
}

typealias BackendController = BackendControllerFeed
