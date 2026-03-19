module BadgesHelper
  def badge_image(badge, unlocked: true)
    unlocked ? badge.image_path : badge.locked_image_path
  end
end
