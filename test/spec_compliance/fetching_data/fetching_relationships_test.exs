defmodule AshJsonApiTest.FetchingData.FetchingRelationships do
  use ExUnit.Case
  @moduletag :json_api_spec_1_0
  @moduletag :skip

  # credo:disable-for-this-file Credo.Check.Readability.MaxLineLength

  defmodule Author do
    use Ash.Resource,
      domain: AshJsonApiTest.FetchingData.FetchingRelationships.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshJsonApi.Resource]

    ets do
      private?(true)
    end

    json_api do
      type("author")

      routes do
        base("/authors")
        get(:read)
        index(:read)
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    relationships do
      has_many(:posts, AshJsonApiTest.FetchingData.FetchingRelationships.Post,
        public?: true,
        destination_attribute: :author_id
      )
    end
  end

  defmodule Post do
    use Ash.Resource,
      domain: AshJsonApiTest.FetchingData.FetchingRelationships.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshJsonApi.Resource]

    ets do
      private?(true)
    end

    json_api do
      type("post")

      routes do
        base("/posts")
        get(:read)
        index(:read)
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    relationships do
      belongs_to(:author, Author, public?: true)
    end
  end

  defmodule Domain do
    use Ash.Domain,
      extensions: [
        AshJsonApi.Domain
      ]

    json_api do
      router(AshJsonApiTest.FetchingData.FetchingRelationships.Router)
    end

    resources do
      resource(Author)
      resource(Post)
    end
  end

  defmodule Router do
    use AshJsonApi.Router, domain: Domain
  end

  import AshJsonApi.Test

  @tag :spec_must
  # JSON:API 1.0 Specification
  # --------------------------
  # A server MUST support fetching relationship data for every relationship URL provided as a self link as part of a relationship’s links object.
  # --------------------------
  describe "relationship links" do
    # I'm not sure how to test this...
  end

  @tag :spec_must
  # JSON:API 1.0 Specification
  # --------------------------
  # A server MUST respond to a successful request to fetch a relationship with a 200 OK response.
  # --------------------------
  describe "200 OK response." do
    test "empty to-one relationship" do
      # Create a post without an author
      post =
        Post
        |> Ash.Changeset.for_create(:create, %{name: "foo"})
        |> Ash.create!()

      get(Domain, "/posts/#{post.id}/relationships/author", status: 200)
    end

    test "empty to-many relationship" do
      # Create a post without comments
      {:ok, post} = Ash.create(Post, attributes: %{name: "foo"})

      get(Domain, "/posts/#{post.id}/relationships/comments", status: 200)
    end

    test "non-empty to-one relationship" do
      # Create a post with an author
      {:ok, author} = Ash.create(Author, attributes: %{name: "foo"})

      {:ok, post} =
        Ash.create(Post,
          attributes: %{name: "foo"},
          relationships: %{author: author}
        )

      get(Domain, "/posts/#{post.id}/relationships/author", status: 200)
    end

    test "non-empty to-many relationship" do
      # Create a post with an author
      {:ok, post_1} = Ash.create(Post, attributes: %{name: "First Post"})
      {:ok, post_2} = Ash.create(Post, attributes: %{name: "Second Post"})

      {:ok, author} =
        Ash.create(Author,
          attributes: %{name: "foo"},
          relationships: %{posts: [post_1, post_2]}
        )

      get(Domain, "/authors/#{author.id}/relationships/posts", status: 200)
    end
  end

  @tag :spec_must
  # JSON:API 1.0 Specification
  # --------------------------
  # The primary data in the response document MUST match the appropriate value for resource linkage, as described above for relationship objects.
  # --------------------------
  describe "primary data resource linkage" do
  end

  @tag :spec_may
  # JSON:API 1.0 Specification
  # --------------------------
  # The top-level links object MAY contain self and related links, as described above for relationship objects.
  # --------------------------
  describe "top-level links object" do
    # Do we want to implement this?
  end

  @tag :spec_must
  # JSON:API 1.0 Specification
  # --------------------------
  # A server MUST return 404 Not Found when processing a request to fetch a relationship link URL that does not exist.
  # --------------------------
  describe "404 Not Found" do
    # Note: This can happen when the parent resource of the relationship does not exist. For example, when /articles/1 does not exist, request to /articles/1/relationships/tags returns 404 Not Found.
    # If a relationship link URL exists but the relationship is empty, then 200 OK MUST be returned, as described above.
  end

  @tag :spec_may
  # JSON:API 1.0 Specification
  # --------------------------
  # A server MAY respond with other HTTP status codes.
  # --------------------------
  describe "other responses" do
    # Do we want to implement this?
    # I'm not sure how to test this...
  end

  @tag :spec_may
  # JSON:API 1.0 Specification
  # --------------------------
  # A server MAY include error details with error responses.
  # --------------------------
  describe "error responses" do
    # Do we want to implement this?
    # Need to come up with error scenarios if so
  end

  @tag :spec_must
  # JSON:API 1.0 Specification
  # --------------------------
  # A server MUST prepare responses in accordance with HTTP semantics.
  # --------------------------
  describe "HTTP semantics" do
    # I'm not sure how to test this...
  end
end
