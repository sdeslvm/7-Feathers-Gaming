import Foundation
import SwiftUI

struct FeathersEntryScreen: View {
    @StateObject private var loader: FeathersWebLoader

    init(loader: FeathersWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            FeathersWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                FeathersProgressIndicator(value: percent)
            case .failure(let err):
                FeathersErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                FeathersOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct FeathersProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            FeathersLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct FeathersErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct FeathersOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
