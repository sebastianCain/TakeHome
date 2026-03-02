// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension GraphQL {
  class BirdsQuery: GraphQLQuery {
    static let operationName: String = "birds"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query birds { birds { __typename id thumb_url image_url latin_name english_name notes { __typename id comment timestamp } } }"#
      ))

    public init() {}

    struct Data: GraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { GraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("birds", [Bird].self),
      ] }

      var birds: [Bird] { __data["birds"] }

      /// Bird
      ///
      /// Parent Type: `Bird`
      struct Bird: GraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { GraphQL.Objects.Bird }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphQL.ID.self),
          .field("thumb_url", String.self),
          .field("image_url", String.self),
          .field("latin_name", String.self),
          .field("english_name", String.self),
          .field("notes", [Note].self),
        ] }

        var id: GraphQL.ID { __data["id"] }
        var thumb_url: String { __data["thumb_url"] }
        var image_url: String { __data["image_url"] }
        var latin_name: String { __data["latin_name"] }
        var english_name: String { __data["english_name"] }
        var notes: [Note] { __data["notes"] }

        /// Bird.Note
        ///
        /// Parent Type: `Note`
        struct Note: GraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { GraphQL.Objects.Note }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GraphQL.ID.self),
            .field("comment", String.self),
            .field("timestamp", Int.self),
          ] }

          var id: GraphQL.ID { __data["id"] }
          var comment: String { __data["comment"] }
          var timestamp: Int { __data["timestamp"] }
        }
      }
    }
  }

}