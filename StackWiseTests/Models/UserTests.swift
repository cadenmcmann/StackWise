import Testing
import Foundation
@testable import StackWise

@Suite("User Model Tests")
struct UserTests {
    
    // MARK: - Display Name Tests
    
    @Test("displayName returns full name when both first and last name are present")
    func displayNameFullName() {
        let user = TestHelpers.makeUser(firstName: "John", lastName: "Doe")
        #expect(user.displayName == "John Doe")
    }
    
    @Test("displayName returns first name only when last name is nil")
    func displayNameFirstNameOnly() {
        let user = TestHelpers.makeUser(firstName: "John", lastName: nil)
        #expect(user.displayName == "John")
    }
    
    @Test("displayName returns email when no name is present")
    func displayNameFallsBackToEmail() {
        let user = TestHelpers.makeUser(
            email: "john@example.com",
            firstName: nil,
            lastName: nil
        )
        #expect(user.displayName == "john@example.com")
    }
    
    @Test("displayName returns nil when no name or email")
    func displayNameReturnsNil() {
        let user = TestHelpers.makeUser(
            email: nil,
            firstName: nil,
            lastName: nil
        )
        #expect(user.displayName == nil)
    }
    
    // MARK: - Initials Tests
    
    @Test("initials returns first letters of first and last name")
    func initialsFullName() {
        let user = TestHelpers.makeUser(firstName: "John", lastName: "Doe")
        #expect(user.initials == "JD")
    }
    
    @Test("initials returns first two letters of first name when no last name")
    func initialsFirstNameOnly() {
        let user = TestHelpers.makeUser(firstName: "John", lastName: nil)
        #expect(user.initials == "JO")
    }
    
    @Test("initials returns first letter of email when no name")
    func initialsFallsBackToEmail() {
        let user = TestHelpers.makeUser(
            email: "john@example.com",
            firstName: nil,
            lastName: nil
        )
        #expect(user.initials == "J")
    }
    
    @Test("initials returns U when no name or email")
    func initialsDefaultsToU() {
        let user = TestHelpers.makeUser(
            email: nil,
            firstName: nil,
            lastName: nil
        )
        #expect(user.initials == "U")
    }
    
    @Test("initials are uppercased")
    func initialsAreUppercased() {
        let user = TestHelpers.makeUser(firstName: "john", lastName: "doe")
        #expect(user.initials == "JD")
    }
    
    // MARK: - Codable Tests
    
    @Test("User encodes and decodes correctly")
    func codableRoundtrip() throws {
        let user = TestHelpers.makeUser(
            id: "test-id",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            age: 30,
            sex: .male,
            height: 175,
            weight: 75,
            bodyFat: 15.0,
            stimulantTolerance: .moderate
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)
        
        #expect(decodedUser.id == user.id)
        #expect(decodedUser.email == user.email)
        #expect(decodedUser.firstName == user.firstName)
        #expect(decodedUser.lastName == user.lastName)
        #expect(decodedUser.age == user.age)
        #expect(decodedUser.sex == user.sex)
        #expect(decodedUser.height == user.height)
        #expect(decodedUser.weight == user.weight)
        #expect(decodedUser.bodyFat == user.bodyFat)
        #expect(decodedUser.stimulantTolerance == user.stimulantTolerance)
    }
    
    // MARK: - Enum Tests
    
    @Test("Sex enum has correct raw values")
    func sexEnumRawValues() {
        #expect(User.Sex.male.rawValue == "Male")
        #expect(User.Sex.female.rawValue == "Female")
        #expect(User.Sex.other.rawValue == "Other")
    }
    
    @Test("StimulantTolerance enum has correct raw values")
    func stimulantToleranceEnumRawValues() {
        #expect(User.StimulantTolerance.none.rawValue == "None")
        #expect(User.StimulantTolerance.low.rawValue == "Low")
        #expect(User.StimulantTolerance.moderate.rawValue == "Moderate")
        #expect(User.StimulantTolerance.high.rawValue == "High")
    }
    
    // MARK: - Default Values Tests
    
    @Test("User initializer sets correct default values")
    func defaultValues() {
        let user = User(
            age: 25,
            sex: .other,
            height: 170,
            weight: 70,
            stimulantTolerance: .low
        )
        
        #expect(user.email == nil)
        #expect(user.phoneNumber == nil)
        #expect(user.firstName == nil)
        #expect(user.lastName == nil)
        #expect(user.createdAt == nil)
        #expect(user.bodyFat == nil)
        #expect(!user.id.isEmpty)
    }
}

