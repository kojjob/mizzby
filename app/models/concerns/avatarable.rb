module Avatarable
  extend ActiveSupport::Concern

  def display_avatar(size: 200)
    if profile_picture.attached?
      profile_picture.variant(resize_to_limit: [ size, size ])
    else
      gravatar_url(size: size)
    end
  end

  def gravatar_url(size: 200)
    hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{hash}?d=identicon&s=#{size}"
  end
end
