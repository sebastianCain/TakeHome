//
//  Bird.swift
//  TakeHome
//
//  Created by Sebastian Cain on 3/1/26.
//

struct LocalBird {
    let id: String
    let thumbUrl: String
    let imageUrl: String
    let latinName: String
    let englishName: String
    let notes: [Note]
    
    struct Note {
        let id: String
        let comment: String
        let timestamp: Int
    }
}

extension GraphQL.BirdsQuery.Data.Bird {
    func toLocalBird() -> LocalBird {
        LocalBird(
            id: id,
            thumbUrl: thumb_url,
            imageUrl: image_url,
            latinName: latin_name,
            englishName: english_name,
            notes: notes.map { $0.toLocalNote() }
        )
    }
}

extension GraphQL.BirdsQuery.Data.Bird.Note {
    func toLocalNote() -> LocalBird.Note {
        LocalBird.Note(
            id: id,
            comment: comment,
            timestamp: timestamp
        )
    }
}

extension GraphQL.BirdQuery.Data.Bird {
    func toLocalBird() -> LocalBird {
        LocalBird(
            id: id,
            thumbUrl: thumb_url,
            imageUrl: image_url,
            latinName: latin_name,
            englishName: english_name,
            notes: notes.map { $0.toLocalNote() }
        )
    }
}

extension GraphQL.BirdQuery.Data.Bird.Note {
    func toLocalNote() -> LocalBird.Note {
        LocalBird.Note(
            id: id,
            comment: comment,
            timestamp: timestamp
        )
    }
}
