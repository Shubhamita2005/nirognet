from flask import Blueprint
from app.controllers.auth_controller import (
    register,
    login,
    get_profile,
    update_profile,
    update_health,
    change_password
)

auth_bp = Blueprint("auth", __name__)

# -----------------------
# Auth Routes
# -----------------------

# Register
@auth_bp.route("/api/register", methods=["POST"])
def register_route():
    return register()


# Login
@auth_bp.route("/api/login", methods=["POST"])
def login_route():
    return login()


# -----------------------
# Profile Routes
# -----------------------

# Get Profile
@auth_bp.route("/api/profile", methods=["GET"])
def profile_route():
    return get_profile()


# Update Profile
@auth_bp.route("/api/profile", methods=["PUT"])
def update_profile_route():
    return update_profile()


# -----------------------
# Health Routes
# -----------------------

# Update Health Info
@auth_bp.route("/api/profile/health", methods=["PUT"])
def update_health_route():
    return update_health()


# -----------------------
# Password Routes
# -----------------------

# Change Password
@auth_bp.route("/api/change-password", methods=["PUT"])
def change_password_route():
    return change_password()