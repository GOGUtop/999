import SwiftUI
import SafariServices

struct SafariPortalScreen: View {
    let portal: Portal
    let onSwitchPortal: () -> Void

    @State private var showSafari = true
    @State private var showNovelReader = false
    @State private var showExperimentalWebView = false
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#07111F"), Color(hex: "#102A43"), Color(hex: "#0B2545")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("🐶")
                        .font(.system(size: 64))

                    Text(portal.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("已启用 iOS Safari 兼容模式。这个模式使用系统 Safari 的网页容器，适合 Safari 能打开、WKWebView 一直转圈的 HTTP 狗洞。")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)

                    Text(portal.url)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)
                        .padding(.horizontal, 22)

                    VStack(spacing: 12) {
                        Button {
                            showSafari = true
                        } label: {
                            Label("打开酒馆", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            showExperimentalWebView = true
                        } label: {
                            Label("试试内置 WebView", systemImage: "network")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("狗骨酒馆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("换狗洞") { onSwitchPortal() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("阅读器") { showNovelReader = true }
                    Button("重置") { showResetConfirm = true }
                }
            }
            .fullScreenCover(isPresented: $showSafari) {
                SafariWebView(urlString: portal.url)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showNovelReader) {
                NovelReaderView()
            }
            .sheet(isPresented: $showExperimentalWebView) {
                WebViewScreen(portal: portal, onSwitchPortal: onSwitchPortal)
            }
            .alert("💣 重置网页数据？", isPresented: $showResetConfirm) {
                Button("取消", role: .cancel) {}
                Button("确定重置", role: .destructive) {
                    WebDataCleaner.clearAll { }
                }
            } message: {
                Text("这会清空 iOS WKWebView 的 Cookie、缓存和网页数据。Safari 兼容模式的数据由系统 Safari 管理，如果仍有问题，请在 iPhone 设置里清理 Safari 网站数据。")
            }
        }
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let urlString: String

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let url = URL(string: urlString) ?? URL(string: "about:blank")!
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = false

        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.dismissButtonStyle = .done
        controller.preferredBarTintColor = UIColor.black
        controller.preferredControlTintColor = UIColor.systemBlue
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
