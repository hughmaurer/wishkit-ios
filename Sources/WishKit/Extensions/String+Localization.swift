
import Foundation

extension String {
    func localized(bundle: Bundle = Bundle.module) -> String {
        let localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
        return localizedString
    }
}
