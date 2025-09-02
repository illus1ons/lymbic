
import SwiftUI
import AVFoundation

#if canImport(UIKit)
import UIKit
typealias PlatformView = UIView
#elseif canImport(AppKit)
import AppKit
typealias PlatformView = NSView
#endif

// MARK: - Live Text Camera View
struct LiveTextCameraView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 카메라 프리뷰
            CameraPreviewView()
                .ignoresSafeArea()
            
            // 인식된 텍스트 오버레이 (임시 예시)
            VStack {
                Spacer()
                TextOverlayView()
                
                
                Spacer()
            }
            
            // 상단 / 하단 컨트롤
            VStack {
                TopBar(dismiss: dismiss)
                Spacer()
                BottomControls()
            }
        }
        .onAppear { CameraSession.shared.start() }
        .onDisappear { CameraSession.shared.stop() }
    }
}

// MARK: - Top Bar
private struct TopBar: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button("✕") { dismiss() }
                .font(.title)
                .foregroundColor(.white)
            Spacer()
            Button("완료") { dismiss() }
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .background(.black.opacity(0.5))
    }
}

// MARK: - Bottom Controls
private struct BottomControls: View {
    var body: some View {
        VStack(spacing: 15) {
            Button {
                // TODO: 클립보드에 복사하기 액션
            } label: {
                Label("클립보드에 복사하기", systemImage: "doc.on.clipboard")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            HStack {
                Button {
                    // TODO: 카메라 전환
                } label: {
                    CircleButton(icon: "arrow.triangle.2.circlepath")
                }
                
                Spacer()
                
                Button {
                    // TODO: Live Text 설정
                } label: {
                    CircleButton(icon: "gearshape.fill")
                }
            }
        }
        .padding()
        .background(.black.opacity(0.5))
    }
}

private struct CircleButton: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .padding(10)
            .background(.black.opacity(0.5))
            .clipShape(Circle())
            .foregroundColor(.white)
    }
}

// MARK: - Text Overlay (샘플)
private struct TextOverlayView: View {
    var body: some View {
        VStack {
            Text("실시간으로 인식된 텍스트가\n여기에 하이라이트되어 표시됩니다")
                .multilineTextAlignment(.center)
                .padding()
                .background(.black.opacity(0.6))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .padding()
    }
}

// MARK: - Camera Preview (플랫폼별 구현)
#if canImport(UIKit)
struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        CameraSession.shared.previewView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        CameraSession.shared.previewLayer.frame = uiView.bounds
    }
}
#elseif canImport(AppKit)
struct CameraPreviewView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        CameraSession.shared.previewView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        CameraSession.shared.previewLayer.frame = nsView.bounds
    }
}
#endif

// MARK: - Camera Session Singleton
final class CameraSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = CameraSession()
    
    let session = AVCaptureSession()
    let previewLayer: AVCaptureVideoPreviewLayer
    let previewView: PlatformView
    
    private override init() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        #if canImport(UIKit)
        previewView = UIView()
        previewView.layer.addSublayer(previewLayer)
        #elseif canImport(AppKit)
        previewView = NSView()
        previewView.wantsLayer = true
        previewView.layer = CALayer()
        previewView.layer?.addSublayer(previewLayer)
        #endif
        
        super.init()
    }
    
    func start() {
        guard !session.isRunning else { return }
        setupIfNeeded()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stop() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.stopRunning()
            }
        }
    }
    
    private func setupIfNeeded() {
        guard session.inputs.isEmpty else { return }
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                print("카메라 접근 권한 거부됨")
                return
            }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .back),
                  let input = try? AVCaptureDeviceInput(device: device)
            else { return }
            
            self.session.beginConfiguration()
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
        }
    }
    
    // MARK: - SampleBuffer Delegate
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // TODO: Vision 프레임워크와 연결하여 텍스트 인식 구현
    }
}

// MARK: - Preview
struct LiveTextCameraView_Previews: PreviewProvider {
    static var previews: some View {
        LiveTextCameraView()
    }
}
