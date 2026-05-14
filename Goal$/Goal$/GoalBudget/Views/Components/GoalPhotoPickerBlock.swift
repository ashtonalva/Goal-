import PhotosUI
import SwiftUI
import UIKit

/// Shared photo picker + preview for add and edit flows.
struct GoalPhotoPickerBlock: View {
    @Binding var photoData: Data?

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityLabel("Photo of item preview")

                Button("Remove photo", role: .destructive) {
                    self.photoData = nil
                    pickerItem = nil
                }
                .font(.subheadline)
            } else {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Choose from photo library", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
            }
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let prepared = GoalPhotoProcessing.prepareForStorage(data)
                    await MainActor.run {
                        photoData = prepared
                    }
                }
            }
        }
    }
}
