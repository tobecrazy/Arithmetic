//
//  CachedAsyncImageView.swift
//  Arithmetic
//
//  Created by Qwen Code on 9/14/25.
//

import SwiftUI

struct CachedAsyncImageView: View {
    @State private var image: UIImage?
    @State private var isLoading = false
    private let url: URL?
    private let placeholder: Image
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onAppear(perform: loadImage)
            }
        }
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        ImageCacheManager.shared.downloadAndCacheImage(from: url) { image in
            DispatchQueue.main.async {
                self.image = image
                self.isLoading = false
            }
        }
    }
}

struct CachedAsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        CachedAsyncImageView(
            url: URL(string: "https://images.cnblogs.com/cnblogs_com/tobecrazy/432338/o_250810143405_Card.png"),
            placeholder: Image(systemName: "person.circle.fill")
        )
        .frame(width: 300, height: 200)
        .font(.system(size: 100))
        .foregroundColor(.gray.opacity(0.5))
    }
}