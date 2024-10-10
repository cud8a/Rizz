//
//  Fetcher.swift
//  Rizz
//
//  Created by Tamas Bara on 04.10.24.
//

import Foundation

enum Fetcher {
    
    static var binId = "670534e1acd3cb34a8935b12"
    
    case locations
    case forecast(location: Location)
    case location(name: String)
    case update(model: Record)
    
    var url: URL? {
        switch self {
            
        case .update:
            return URL(string:"https://api.jsonbin.io/v3/b/\(Self.binId)")
            
        case .forecast(let location):
            if let appId = ViewModel.openWeather?.appId {
                return URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.lat)&lon=\(location.lon)&appid=\(appId)&lang=de&units=metric")
            } else {
                DebugLog.log("--- appId is not set")
            }
            
        case .locations:
            return URL(string:"https://api.jsonbin.io/v3/b/\(Self.binId)/latest")
        
        case .location(let name):
            if let apiKey = ViewModel.geoApify?.apiKey {
                return URL(string:"https://api.geoapify.com/v1/geocode/search?text=\(name)&apiKey=\(apiKey)&lang=de")
            }
    }
        
        return nil
    }
    
    var header: [(key: String, value: String)] {
        
        var header = [("Content-Type", "application/json")]
        
        switch self {
        case .locations, .update:
            if let key = Files.accessKey.text {
                header.append(("X-Access-Key", key.trimmingCharacters(in: .newlines)))
            }
        default : ()
        }
        
        return header
    }
    
    func request() throws -> URLRequest? {
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        header.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        switch self {
        case .update(let model):
            request.httpMethod = "PUT"
            request.httpBody = try JSONEncoder().encode(model)
        default: ()
        }
        
        return request
    }
    
    func fetch<R: Codable>() async throws -> R? {
        guard let request = try request() else { return nil }
        let (data, response) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(R.self, from: try mapResponse(response: (data,response)))
    }
    
    enum NetworkError: Error, LocalizedError {
        case missingRequiredFields(String)
        case invalidParameters(operation: String, parameters: [Any])
        case badRequest
        case unauthorized
        case paymentRequired
        case forbidden
        case notFound
        case requestEntityTooLarge
        case unprocessableEntity
        case http(httpResponse: HTTPURLResponse, data: Data)
        case invalidResponse(Data)
        case deleteOperationFailed(String)
        case network(URLError)
        case unknown(Error?)

    }
    
    func mapResponse(response: (data: Data, response: URLResponse)) throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            return response.data
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return response.data
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 402:
            throw NetworkError.paymentRequired
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 413:
            throw NetworkError.requestEntityTooLarge
        case 422:
            throw NetworkError.unprocessableEntity
        default:
            throw NetworkError.http(httpResponse: httpResponse, data: response.data)
        }
    }
}
