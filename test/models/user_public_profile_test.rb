require "test_helper"

class UserPublicProfileTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: "test@example.com",
      password: "password123"
    )
  end

  # Slug validation tests
  test "should accept valid slug formats" do
    valid_slugs = [ "john-doe", "user_123", "test-user", "a12", "abc" ]

    valid_slugs.each do |slug|
      @user.slug = slug
      assert @user.valid?, "Slug '#{slug}' should be valid"
    end
  end

  test "should reject invalid slug formats" do
    invalid_slugs = [ "user@123", "test user", "ab", "a" * 31, "user!" ]

    invalid_slugs.each do |slug|
      @user.slug = slug
      assert_not @user.valid?, "Slug '#{slug}' should be invalid"
    end
  end

  test "should enforce slug uniqueness" do
    @user.update!(slug: "unique-slug")

    other_user = User.new(
      email_address: "other@example.com",
      password: "password123",
      slug: "unique-slug"
    )

    assert_not other_user.valid?
    assert_includes other_user.errors[:slug], "has already been taken"
  end

  test "should normalize slug to lowercase" do
    @user.slug = "MiXeD-CaSe"
    @user.save!
    @user.reload

    assert_equal "mixed-case", @user.slug
  end

  test "slug should be optional" do
    @user.slug = nil
    assert @user.valid?

    @user.slug = ""
    assert @user.valid?
  end

  # Privacy settings tests
  test "should default privacy settings to false" do
    new_user = User.create!(
      email_address: "new@example.com",
      password: "password123"
    )

    assert_equal false, new_user.habits_public?
    assert_equal false, new_user.reflections_public?
  end

  test "should track public profile status" do
    assert_not @user.has_public_profile?

    @user.slug = "test-user"
    assert @user.has_public_profile?
  end

  test "should determine public habits visibility" do
    @user.slug = "test-user"
    @user.habits_public = false
    assert_not @user.public_habits_visible?

    @user.habits_public = true
    assert @user.public_habits_visible?

    @user.slug = nil
    assert_not @user.public_habits_visible?
  end

  test "should determine public reflections visibility" do
    @user.slug = "test-user"
    @user.reflections_public = false
    assert_not @user.public_reflections_visible?

    @user.reflections_public = true
    assert @user.public_reflections_visible?

    @user.slug = nil
    assert_not @user.public_reflections_visible?
  end

  test "with_slug scope should return users with slugs" do
    @user.update!(slug: "has-slug")
    user_without_slug = User.create!(
      email_address: "no-slug@example.com",
      password: "password123"
    )

    users_with_slugs = User.with_slug

    assert_includes users_with_slugs, @user
    assert_not_includes users_with_slugs, user_without_slug
  end
end
