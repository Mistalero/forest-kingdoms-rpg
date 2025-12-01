# Social Networks Configuration
# This file contains configuration settings for social networks integration

extends Node

# Configuration dictionary
var social_networks_config = {
    "mailru": {
        "api_url": "https://www.appsmail.ru/platform/api",
        "oauth_url": "https://connect.mail.ru/oauth/authorize",
        "client_id": "",  # To be filled with actual client ID
        "client_secret": "",  # To be filled with actual client secret
        "redirect_uri": "",  # To be filled with redirect URI
        "permissions": [
            "photos",
            "messages",
            "notifications",
            "stream",
            "offline"
        ]
    },
    "vk": {
        "api_url": "https://api.vk.com/method/",
        "oauth_url": "https://oauth.vk.com/authorize",
        "client_id": "",  # To be filled with actual client ID
        "client_secret": "",  # To be filled with actual client secret
        "redirect_uri": "",  # To be filled with redirect URI
        "api_version": "5.131",
        "permissions": [
            "notify",
            "friends",
            "photos",
            "audio",
            "video",
            "stories",
            "pages",
            "status",
            "notes",
            "messages",
            "wall",
            "ads",
            "offline",
            "docs",
            "groups",
            "notifications",
            "stats",
            "email",
            "market"
        ]
    }
}

func _ready():
    print("Social Networks configuration loaded")

# Get configuration for specific network
func get_network_config(network_name: String) -> Dictionary:
    if social_networks_config.has(network_name):
        return social_networks_config[network_name]
    else:
        print("Configuration for network ", network_name, " not found")
        return {}

# Set client credentials for a network
func set_client_credentials(network_name: String, client_id: String, client_secret: String):
    if social_networks_config.has(network_name):
        social_networks_config[network_name]["client_id"] = client_id
        social_networks_config[network_name]["client_secret"] = client_secret
        print("Credentials set for ", network_name)
    else:
        print("Network ", network_name, " not found in configuration")