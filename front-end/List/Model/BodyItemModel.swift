//
//  BodyItemModel.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct BodyItem: Codable {
    var id: String
    var user: ShoppingListUser
    var text: String
    var hyperLink: String
    var containsImage: Bool
    var image: Data?
    
   init(id:String, user:ShoppingListUser, text:String, hyperLink:String, containsImage: Bool, image: UIImage?) {
        self.id = id
        self.user = user
        self.text = text
        self.hyperLink = hyperLink
        self.containsImage = containsImage
        if image != nil {
            self.image = image?.jpegData(compressionQuality: 1)
        }
    }
    
    func getImage() -> UIImage? {
        guard let imageData = self.image else {
            return nil
        }
        let image = UIImage(data: imageData)
        
        return image
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, user, text, hyperLink, containsImage
    }
    
}

