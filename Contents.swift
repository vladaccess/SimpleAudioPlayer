import AVFoundation

enum AudioPlayerError: Error {
    case fileExtension, fileNotFound
}

protocol Player {
    var isPlaying: Bool { get }
    var completionHandler: ((_ didFinish: Bool) -> Void)? { get set }
    
    func play()
    func stop()
}

class AudioPlayer: NSObject {
    
    typealias SoundDidFinishCompletion = (_ didFinish: Bool) -> Void
    
    var completionHandler: SoundDidFinishCompletion?
    
    private let url: URL
    private let name: String
    private let player: AVAudioPlayer?
    
    convenience init(fileName: String) throws {
        let components = fileName.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ".")
        guard components.count == 2 else {
            throw AudioPlayerError.fileExtension
        }
        guard let url = Bundle.main.url(forResource: components[0], withExtension: components[1]) else {
            throw AudioPlayerError.fileNotFound
        }
        try self.init(contentsOf: url)
    }
    
    convenience init(contentsOfPath path: String) throws {
        let fileURL = URL(fileURLWithPath: path)
        try self.init(contentsOf: fileURL)
    }
    
    init(contentsOf url: URL) throws {
        self.url = url
        name = url.lastPathComponent
        player = try AVAudioPlayer(contentsOf: url)
        super.init()
        player?.delegate = self
    }
    
    deinit {
        player?.delegate = nil
    }
}

extension AudioPlayer: Player {
    
    var isPlaying: Bool {
        guard let notNilsound = player else {
            return false
        }
        return notNilsound.isPlaying
    }
    
    func play() {
        guard !isPlaying else { return }
        player?.play()
    }
    
    func stop() {
        guard isPlaying else { return }
        soundDidFinish(successfuly: false)
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        soundDidFinish(successfuly: flag)
    }
}

extension AudioPlayer {
    private func soundDidFinish(successfuly: Bool) {
        player?.stop()
        
        if let nonNilCompletionHandler = completionHandler {
            nonNilCompletionHandler(successfuly)
        }
    }
}
