# frozen_string_literal: true

# ISK - A web controllable slideshow system
#
# Author::		Vesa-Pekka Palmu
# Copyright:: Copyright (c) Vesa-Pekka Palmu
# License::		Licensed under GPL v3, see LICENSE.md

class UsersController < ApplicationController
  # ACLs, we require global admin priviledges for all user operations
  before_action :require_global_admin

  # List all users
  def index
    @users = User.order(:username).all
  end

  # Generate a form for adding/removing roles from a user
  def roles
    @user = User.find(params[:id])
    @roles = Role.order("role").all
  end

  # Grant roles to a user
  def grant
    user = User.find(params[:id])

    # Iterate over the posted hash of permissions
    # If it is checked we add it (if needed) and if not
    # we remove the role from the user (if needed)
    params[:roles].each_pair do |role_id, checked|
      r = Role.find(role_id)
      if checked.to_i == 1
        # User should have this role
        user.roles << r unless user.roles.include?(r)
      elsif user.roles.include?(r)
        # User shouldn't have this role
        user.roles.delete(r)
      end
    end
    user.save!
    flash[:notice] = "User roles changed"
    redirect_to users_path
  end

  # A form for creating a new user
  def new
    @user = User.new
  end

  # Create a new user
  # TODO: password verification into the model?
  def create
    User.transaction do
      @user = User.new
      @user.username = params[:user][:username]
      if verify_password
        @user.password = params[:password][:password]
        if @user.save
          flash[:notice] = "User created."
          redirect_to users_path
          return
        end
      else
        @user.errors.add("Password", "verification error")
      end
      flash[:error] = "Error creating user"
      render action: :new
    end
  end

  # Show details of a user
  def show
    @user = User.find(params[:id])
  end

  # Render a edit form for user
  # Currently only the username can be changed here
  # TODO: Merge role management to same edit system!
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    unless params[:password][:password].empty?
      if verify_password
        @user.password = params[:password][:password]
      else
        @user.errors.add("Password", "verification error")
        render action: :edit
        return
      end
    end
    if @user.save
      flash[:notice] = "User updated."
      redirect_to users_path
    else
      render action: :edit
    end
  end

  # Delete a user
  def destroy
    user = User.find(params[:id])

    # Disallow current user deleting itself
    if user.id == current_user.id
      flash[:error] = "You cannot delete your own user account!"
    else
      user.destroy
      flash[:notice] = "User #{user.username} has been deleted."
    end
    redirect_to users_path
  end

private

  def verify_password
    params[:password][:password] == params[:password][:verify]
  end
end
