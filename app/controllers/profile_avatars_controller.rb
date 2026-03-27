class ProfileAvatarsController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(profile_avatar_params)
      render json: {
        avatar_key: current_user.avatar_key,
        avatar_name: current_user.avatar_name,
        avatar_asset: view_context.asset_path(current_user.avatar_asset)
      }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile_avatar_params
    params.require(:user).permit(:avatar_key)
  end
end
