//
//  ImageItemView.swift
//  List
//
//  Created by Michael Kilgore on 9/17/21.
//

import SwiftUI

struct ImageItemView: View {
    var image: UIImage
    
    var body: some View {
        if image != UIImage() {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "camera")
                .resizable()
                .scaledToFill()
                .padding(50)
                .background(
                    Color(hex: 0x808080)
                )
        }
            
    }
}

struct ImageItemView_Previews: PreviewProvider {
    static var previews: some View {
        ImageItemView(image: UIImage())
            .frame(width: 300, height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
