import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct FeathersLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        FeathersProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct FeathersBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct FeathersProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var particleAnimation = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with neon glow
                backgroundTrack(height: geometry.size.height)

                // Main progress track
                progressTrack(in: geometry)

                // Moving particles
                particleEffects(in: geometry)

                // Shimmer effect
                shimmerEffect(in: geometry)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0A0A0A"), Color(hex: "#1A1A2E"), Color(hex: "#16213E"),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.cyan.opacity(0.2), radius: 8, y: 0)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "#00F5FF"), location: 0.0),
                        .init(color: Color(hex: "#1E90FF"), location: 0.5),
                        .init(color: Color(hex: "#FF6B6B"), location: 1.0),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .overlay(
                // Inner glow
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.6), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: height / 2
                        )
                    )
                    .frame(width: width, height: height * 0.6)
            )
            .shadow(color: Color.cyan, radius: 12, y: 0)
            .shadow(color: Color.blue.opacity(0.8), radius: 6, y: 0)
            .animation(.easeInOut(duration: 0.8), value: value)
    }

    private func particleEffects(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return HStack(spacing: 2) {
            ForEach(0..<Int(width / 8), id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.cyan, Color.blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 3)
                    .opacity(particleAnimation ? 0.8 : 0.2)
                    .scaleEffect(particleAnimation ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: particleAnimation
                    )
            }
        }
        .frame(width: width, height: height, alignment: .leading)
        .clipped()
    }

    private func shimmerEffect(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.6),
                        Color.clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 30, height: height)
            .offset(x: shimmerOffset * (width + 30))
            .clipped()
            .mask(
                RoundedRectangle(cornerRadius: height / 2)
                    .frame(width: width, height: height)
            )
    }

    private func startAnimations() {
        // Shimmer animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.0
        }

        // Particle animation
        withAnimation(.easeInOut(duration: 0.5)) {
            particleAnimation = true
        }
    }
}

// MARK: - Превью

#Preview("Vertical") {
    FeathersLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    FeathersLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
