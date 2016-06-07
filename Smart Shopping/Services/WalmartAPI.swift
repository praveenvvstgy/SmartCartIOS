//
//  WalmartAPI.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/3/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import Siesta
import SwiftyJSON

class WalmartAPI: Service {
    
    init() {
        super.init(baseURL: "https://api.walmartlabs.com/v1")
        Siesta.enabledLogCategories = LogCategory.detailed
        super.configure {
            $0.config.responseTransformers.add(SwiftyJSONTransformer, contentTypes: ["*/json"])
        }
        super.configureTransformer("/search") {
            ($0.content as JSON)["items"].arrayValue.map(BaseItem.init)
        }
        super.configureTransformer("/items") {
            ($0.content as JSON)["items"].arrayValue.map(BaseItem.init)
        }
        super.configureTransformer("/postbrowse") {
            ($0.content as JSON).arrayValue.map(BaseItem.init)
        }
    }
    
    func search(query: String) -> Resource {
        return resource("search").withParam("query", query).withParam("apiKey", "gz4dz34xf3bjbtwmbqgj3kg7")
    }
    
    func products(products: [Int]) -> Resource {
        return resource("items").withParam("ids", products.map(String.init).joinWithSeparator(",")).withParam("apiKey", "gz4dz34xf3bjbtwmbqgj3kg7")
    }
    
    func recommendations(product: Int) -> Resource {
        return resource("postbrowse").withParam("itemId", String(product)).withParam("apiKey", "gz4dz34xf3bjbtwmbqgj3kg7")
    }
}

private let SwiftyJSONTransformer = ResponseContentTransformer(skipWhenEntityMatchesOutputType: false) {
    JSON($0.content as AnyObject)
}

let walmartAPI = WalmartAPI()