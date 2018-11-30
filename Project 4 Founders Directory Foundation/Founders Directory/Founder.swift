//
//  Founder.swift
//  Founders Directory
//
//  Created by Steve Liddle on 9/21/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import Foundation
import GRDB

class Founder : Record {

    // MARK: - Properties

    var id: Int
    var givenNames: String
    var surnames: String
    var preferredFirstName: String
    var preferredFullName: String
    var cell: String
    var email: String
    var website: String
    var linkedIn: String
    var biography: String
    var expertise: String
    var spouseGivenNames: String
    var spouseSurnames: String
    var spousePreferredFirstName: String
    var spousePreferredFullName: String
    var spouseCell: String
    var spouseEmail: String
    var status: String
    var yearJoined: String
    var homeAddress1: String
    var homeAddress2: String
    var homeCity: String
    var homeState: String
    var homeZip: String
    var homeCountry: String
    var organizationName: String
    var jobTitle: String
    var workAddress1: String
    var workAddress2: String
    var workCity: String
    var workState: String
    var workZip: String
    var workCountry: String
    var mailingAddress1: String
    var mailingAddress2: String
    var mailingCity: String
    var mailingState: String
    var mailingZip: String
    var mailingCountry: String
    var mailingSameAs: String
    var imageUrl: String
    var spouseImageUrl: String
    var registrationId: String
    var isPostAdmin: Bool
    var isPhoneListed: Bool
    var isEmailListed: Bool
    var version: Int
    var deleted: Int
    var dirty: Int
    var new: Int

    // MARK: - Table mapping

    override static var databaseTableName: String {
        return "founder"
    }

    // MARK: - Field names

    struct Field {
        static let id = "id"
        static let givenNames = "given_names"
        static let surnames = "surnames"
        static let preferredFirstName = "preferred_first_name"
        static let preferredFullName = "preferred_full_name"
        static let cell = "cell"
        static let email = "email"
        static let website = "web_site"
        static let linkedIn = "linked_in"
        static let biography = "biography"
        static let expertise = "expertise"
        static let spouseGivenNames = "spouse_given_names"
        static let spouseSurnames = "spouse_surnames"
        static let spousePreferredFirstName = "spouse_preferred_first_name"
        static let spousePreferredFullName = "spouse_preferred_full_name"
        static let spouseCell = "spouse_cell"
        static let spouseEmail = "spouse_email"
        static let status = "status"
        static let yearJoined = "year_joined"
        static let homeAddress1 = "home_address1"
        static let homeAddress2 = "home_address2"
        static let homeCity = "home_city"
        static let homeState = "home_state"
        static let homeZip = "home_postal_code"
        static let homeCountry = "home_country"
        static let organizationName = "organization_name"
        static let jobTitle = "job_title"
        static let workAddress1 = "work_address1"
        static let workAddress2 = "work_address2"
        static let workCity = "work_city"
        static let workState = "work_state"
        static let workZip = "work_postal_code"
        static let workCountry = "work_country"
        static let mailingAddress1 = "mailing_address1"
        static let mailingAddress2 = "mailing_address2"
        static let mailingCity = "mailing_city"
        static let mailingState = "mailing_state"
        static let mailingZip = "mailing_postal_code"
        static let mailingCountry = "mailing_country"
        static let mailingSameAs = "mailing_same_as"
        static let imageUrl = "image_url"
        static let spouseImageUrl = "spouse_image_url"
        static let registrationId = "registration_id"
        static let isPostAdmin = "post_admin"
        static let isPhoneListed = "is_phone_listed"
        static let isEmailListed = "is_email_listed"
        static let version = "version"
        static let deleted = "deleted"
        static let dirty = "dirty"
        static let new = "new"
    }

    static let allFieldsIdVersion = [
        Field.id, Field.givenNames, Field.surnames, Field.preferredFirstName,
        Field.preferredFullName, Field.cell, Field.email, Field.website, Field.linkedIn,
        Field.biography, Field.expertise, Field.spouseGivenNames, Field.spouseSurnames,
        Field.spousePreferredFirstName, Field.spousePreferredFullName, Field.spouseCell,
        Field.spouseEmail, Field.status, Field.yearJoined, Field.homeAddress1, Field.homeAddress2,
        Field.homeCity, Field.homeState, Field.homeZip, Field.homeCountry, Field.organizationName,
        Field.jobTitle, Field.workAddress1, Field.workAddress2, Field.workCity, Field.workState,
        Field.workZip, Field.workCountry, Field.mailingAddress1, Field.mailingAddress2,
        Field.mailingCity, Field.mailingState, Field.mailingZip, Field.mailingCountry,
        Field.mailingSameAs, Field.imageUrl, Field.spouseImageUrl, Field.registrationId,
        Field.isPostAdmin, Field.isPhoneListed, Field.isEmailListed, Field.version
    ]

    struct Flag {
        static let admin = "1"
        static let available = "0"
        static let clean = "0"
        static let deleted = "1"
        static let dirty = "1"
        static let existing = "0"
        static let listed = "1"
        static let new = "1"
        static let normal = "0"
        static let unlisted = "0"
    }

    // MARK: - Initialization

    override init() {
        id = 0
        givenNames = ""
        surnames = ""
        preferredFirstName = ""
        preferredFullName = ""
        cell = ""
        email = ""
        website = ""
        linkedIn = ""
        biography = ""
        expertise = ""
        spouseGivenNames = ""
        spouseSurnames = ""
        spousePreferredFirstName = ""
        spousePreferredFullName = ""
        spouseCell = ""
        spouseEmail = ""
        status = ""
        yearJoined = ""
        homeAddress1 = ""
        homeAddress2 = ""
        homeCity = ""
        homeState = ""
        homeZip = ""
        homeCountry = ""
        organizationName = ""
        jobTitle = ""
        workAddress1 = ""
        workAddress2 = ""
        workCity = ""
        workState = ""
        workZip = ""
        workCountry = ""
        mailingAddress1 = ""
        mailingAddress2 = ""
        mailingCity = ""
        mailingState = ""
        mailingZip = ""
        mailingCountry = ""
        mailingSameAs = ""
        imageUrl = ""
        spouseImageUrl = ""
        registrationId = ""
        isPostAdmin = false
        isPhoneListed = true
        isEmailListed = true
        version = 0
        deleted = 0
        dirty = 0
        new = 1

        super.init()
    }

    required init(row: Row) {
        id = row[Field.id]
        givenNames = row[Field.givenNames]
        surnames = row[Field.surnames]
        preferredFirstName = row[Field.preferredFirstName]
        preferredFullName = row[Field.preferredFullName]
        cell = row[Field.cell]
        email = row[Field.email]
        website = row[Field.website]
        linkedIn = row[Field.linkedIn]
        biography = row[Field.biography]
        expertise = row[Field.expertise]
        spouseGivenNames = row[Field.spouseGivenNames]
        spouseSurnames = row[Field.spouseSurnames]
        spousePreferredFirstName = row[Field.spousePreferredFirstName]
        spousePreferredFullName = row[Field.spousePreferredFullName]
        spouseCell = row[Field.spouseCell]
        spouseEmail = row[Field.spouseEmail]
        status = row[Field.status]
        yearJoined = row[Field.yearJoined]
        homeAddress1 = row[Field.homeAddress1]
        homeAddress2 = row[Field.homeAddress2]
        homeCity = row[Field.homeCity]
        homeState = row[Field.homeState]
        homeZip = row[Field.homeZip]
        homeCountry = row[Field.homeCountry]
        organizationName = row[Field.organizationName]
        jobTitle = row[Field.jobTitle]
        workAddress1 = row[Field.workAddress1]
        workAddress2 = row[Field.workAddress2]
        workCity = row[Field.workCity]
        workState = row[Field.workState]
        workZip = row[Field.workZip]
        workCountry = row[Field.workCountry]
        mailingAddress1 = row[Field.mailingAddress1]
        mailingAddress2 = row[Field.mailingAddress2]
        mailingCity = row[Field.mailingCity]
        mailingState = row[Field.mailingState]
        mailingZip = row[Field.mailingZip]
        mailingCountry = row[Field.mailingCountry]
        mailingSameAs = row[Field.mailingSameAs]
        imageUrl = row[Field.imageUrl]
        spouseImageUrl = row[Field.spouseImageUrl]
        registrationId = row[Field.registrationId]
        isPostAdmin = row[Field.isPostAdmin]
        isPhoneListed = row[Field.isPhoneListed]
        isEmailListed = row[Field.isEmailListed]
        version = row[Field.version]
        deleted = row[Field.deleted]
        dirty = row[Field.dirty]
        new = row[Field.new]
        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container[Field.givenNames] = givenNames
        container[Field.surnames] = surnames
        container[Field.preferredFirstName] = preferredFirstName
        container[Field.preferredFullName] = preferredFullName
        container[Field.cell] = cell
        container[Field.email] = email
        container[Field.website] = website
        container[Field.linkedIn] = linkedIn
        container[Field.biography] = biography
        container[Field.expertise] = expertise
        container[Field.spouseGivenNames] = spouseGivenNames
        container[Field.spouseSurnames] = spouseSurnames
        container[Field.spousePreferredFirstName] = spousePreferredFirstName
        container[Field.spousePreferredFullName] = spousePreferredFullName
        container[Field.spouseCell] = spouseCell
        container[Field.spouseEmail] = spouseEmail
        container[Field.status] = status
        container[Field.yearJoined] = yearJoined
        container[Field.homeAddress1] = homeAddress1
        container[Field.homeAddress2] = homeAddress2
        container[Field.homeCity] = homeCity
        container[Field.homeState] = homeState
        container[Field.homeZip] = homeZip
        container[Field.homeCountry] = homeCountry
        container[Field.organizationName] = organizationName
        container[Field.jobTitle] = jobTitle
        container[Field.workAddress1] = workAddress1
        container[Field.workAddress2] = workAddress2
        container[Field.workCity] = workCity
        container[Field.workState] = workState
        container[Field.workZip] = workZip
        container[Field.workCountry] = workCountry
        container[Field.mailingAddress1] = mailingAddress1
        container[Field.mailingAddress2] = mailingAddress2
        container[Field.mailingCity] = mailingCity
        container[Field.mailingState] = mailingState
        container[Field.mailingZip] = mailingZip
        container[Field.mailingCountry] = mailingCountry
        container[Field.mailingSameAs] = mailingSameAs
        container[Field.imageUrl] = imageUrl
        container[Field.spouseImageUrl] = spouseImageUrl
        container[Field.registrationId] = registrationId
        container[Field.isPostAdmin] = isPostAdmin
        container[Field.isPhoneListed] = isPhoneListed
        container[Field.isEmailListed] = isEmailListed
        container[Field.version] = version
        container[Field.deleted] = deleted
        container[Field.dirty] = dirty
        container[Field.new] = new
    }
    
    func update(from json: JSONObject) {
        givenNames = json[Field.givenNames] as! String
        surnames = json[Field.surnames] as! String
        preferredFirstName = json[Field.preferredFirstName] as! String
        preferredFullName = json[Field.preferredFullName] as! String
        cell = json[Field.cell] as! String
        email = json[Field.email] as! String
        website = json[Field.website] as! String
        linkedIn = json[Field.linkedIn] as! String
        biography = json[Field.biography] as! String
        expertise = json[Field.expertise] as! String
        spouseGivenNames = json[Field.spouseGivenNames] as! String
        spouseSurnames = json[Field.spouseSurnames] as! String
        spousePreferredFirstName = json[Field.spousePreferredFirstName] as! String
        spousePreferredFullName = json[Field.spousePreferredFullName] as! String
        spouseCell = json[Field.spouseCell] as! String
        spouseEmail = json[Field.spouseEmail] as! String
        status = json[Field.status] as! String
        yearJoined = json[Field.yearJoined] as! String
        homeAddress1 = json[Field.homeAddress1] as! String
        homeAddress2 = json[Field.homeAddress2] as! String
        homeCity = json[Field.homeCity] as! String
        homeState = json[Field.homeState] as! String
        homeZip = json[Field.homeZip] as! String
        homeCountry = json[Field.homeCountry] as! String
        organizationName = json[Field.organizationName] as! String
        jobTitle = json[Field.jobTitle] as! String
        workAddress1 = json[Field.workAddress1] as! String
        workAddress2 = json[Field.workAddress2] as! String
        workCity = json[Field.workCity] as! String
        workState = json[Field.workState] as! String
        workZip = json[Field.workZip] as! String
        workCountry = json[Field.workCountry] as! String
        mailingAddress1 = json[Field.mailingAddress1] as! String
        mailingAddress2 = json[Field.mailingAddress2] as! String
        mailingCity = json[Field.mailingCity] as! String
        mailingState = json[Field.mailingState] as! String
        mailingZip = json[Field.mailingZip] as! String
        mailingCountry = json[Field.mailingCountry] as! String
        mailingSameAs = json[Field.mailingSameAs] as! String
        imageUrl = json[Field.imageUrl] as! String
        spouseImageUrl = json[Field.spouseImageUrl] as! String
        registrationId = json[Field.registrationId] as! String
        isPostAdmin = json[Field.isPostAdmin] as! String == Flag.admin
        isPhoneListed = json[Field.isPhoneListed] as! String == Flag.listed
        isEmailListed = json[Field.isEmailListed] as! String == Flag.listed
        version = Int(json[Field.version] as! String) ?? 0
    }

    // MARK: - Helpers

    func fullName() -> String {
        if preferredFullName.isEmpty {
            return "\(givenNames) \(surnames)"
        } else {
            return preferredFullName
        }
    }

    func spouseFullname() -> String {
        if spousePreferredFullName.isEmpty {
            return "\(spouseGivenNames) \(spouseSurnames)"
        } else {
            return spousePreferredFullName
        }
    }

    func organizationLine() -> String? {
        if organizationName.isEmpty && jobTitle.isEmpty {
            return nil
        }

        if jobTitle.isEmpty {
            return organizationName
        }

        return "\(organizationName), \(jobTitle)"
    }
    
    func listedCellEmail() -> String? {
        let listedEmail = isEmailListed ? email : ""
        let listedCell = isPhoneListed ? cell : ""
        
        if listedCell.length > 0 {
            if !listedEmail.isEmpty {
                return "\(listedCell), \(listedEmail)"
            }
            
            return listedCell
        }
        
        return listedEmail
    }

    func listedSpouseCellEmail() -> String? {
        let listedEmail = isEmailListed ? spouseEmail : ""
        let listedCell = isPhoneListed ? spouseCell : ""
        
        if listedCell.length > 0 {
            if !listedEmail.isEmpty {
                return "\(listedCell), \(listedEmail)"
            }
            
            return listedCell
        }

        return listedEmail
    }
}
