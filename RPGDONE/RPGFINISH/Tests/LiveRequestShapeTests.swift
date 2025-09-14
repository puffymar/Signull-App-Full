#if canImport(XCTest)
import XCTest
@testable import RPGFINISH

final class LiveRequestShapeTests: XCTestCase {
    
    func test_RequestShape_has_expected_keys() throws {
        let req = LiveRequest(
            model: "gpt-5-mini",
            messages: [
                LiveRequest.Message(role: "system", content: "test"),
                LiveRequest.Message(role: "user", content: "ping")
            ],
            response_format: LiveRequest.ResponseFormat(
                type: "json_schema",
                schema: ["type": "object"]
            ),
            temperature: 0.8,
            max_tokens: 512,
            stream: true
        )
        
        let data = try JSONEncoder().encode(req)
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        // Verify required fields exist
        XCTAssertNotNil(obj["model"])
        XCTAssertNotNil(obj["messages"])
        XCTAssertNotNil(obj["response_format"])
        XCTAssertNotNil(obj["temperature"])
        XCTAssertNotNil(obj["max_tokens"])
        XCTAssertNotNil(obj["stream"])
        
        // Verify no camelCase leakage
        XCTAssertNil(obj["maxTokens"])
        XCTAssertNil(obj["responseFormat"])
        
        // Verify messages structure
        if let messages = obj["messages"] as? [[String: Any]] {
            XCTAssertEqual(messages.count, 2)
            XCTAssertEqual(messages[0]["role"] as? String, "system")
            XCTAssertEqual(messages[1]["role"] as? String, "user")
        } else {
            XCTFail("Messages should be an array")
        }
    }
    
    func test_ResponseFormat_encoding() throws {
        let schema = [
            "type": "object",
            "properties": ["test": ["type": "string"]]
        ] as [String: Any]
        
        let format = LiveRequest.ResponseFormat(
            type: "json_schema",
            schema: schema
        )
        
        let data = try JSONEncoder().encode(format)
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(obj["type"] as? String, "json_schema")
        XCTAssertNotNil(obj["schema"])
        
        // Verify schema is encoded as string
        if let schemaString = obj["schema"] as? String {
            let decodedSchema = try JSONSerialization.jsonObject(with: Data(schemaString.utf8)) as! [String: Any]
            XCTAssertEqual(decodedSchema["type"] as? String, "object")
        } else {
            XCTFail("Schema should be encoded as string")
        }
    }
    
    func test_Message_encoding() throws {
        let message = LiveRequest.Message(role: "user", content: "test content")
        let data = try JSONEncoder().encode(message)
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(obj["role"] as? String, "user")
        XCTAssertEqual(obj["content"] as? String, "test content")
    }
}
#endif