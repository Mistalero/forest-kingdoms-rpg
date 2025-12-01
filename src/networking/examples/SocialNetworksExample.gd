# Social Networks Integration Example
# This is an example of how to use the social networks integration module

extends Node

# Reference to the social networks API module
var social_networks_api
# Reference to the OAuth handler
var oauth_handler
# Reference to the configuration
var social_networks_config

func _ready():
    # Initialize the social networks integration modules
    social_networks_api = preload("res://networking/social-networks-integration/social_networks_api.gd").new()
    oauth_handler = preload("res://networking/social-networks-integration/oauth_handler.gd").new()
    social_networks_config = preload("res://networking/social-networks-integration/social_networks_config.gd").new()
    
    # Connect to OAuth signals
    oauth_handler.connect("authentication_success", self, "_on_authentication_success")
    oauth_handler.connect("authentication_failed", self, "_on_authentication_failed")
    
    print("Social Networks Integration Example initialized")

# Function to demonstrate Mail.ru integration
func demo_mailru_integration():
    print("Demonstrating Mail.ru integration")
    
    # Get Mail.ru configuration
    var mailru_config = social_networks_config.get_network_config("mailru")
    if mailru_config.empty():
        print("Mail.ru configuration not found")
        return
    
    # Initialize connection
    var success = social_networks_api.initialize_connection("mailru")
    if not success:
        print("Failed to initialize Mail.ru connection")
        return
    
    print("Mail.ru connection initialized successfully")
    
    # Start OAuth flow
    oauth_handler.start_oauth_flow("mailru", mailru_config)

# Function to demonstrate VK integration
func demo_vk_integration():
    print("Demonstrating VK integration")
    
    # Get VK configuration
    var vk_config = social_networks_config.get_network_config("vk")
    if vk_config.empty():
        print("VK configuration not found")
        return
    
    # Initialize connection
    var success = social_networks_api.initialize_connection("vk")
    if not success:
        print("Failed to initialize VK connection")
        return
    
    print("VK connection initialized successfully")
    
    # Start OAuth flow
    oauth_handler.start_oauth_flow("vk", vk_config)

# Function to demonstrate content sharing
func demo_content_sharing(network_name: String):
    print("Demonstrating content sharing on ", network_name)
    
    var content = {
        "message": "I just achieved a new level in Forest Kingdoms RPG!",
        "image": "res://screenshots/latest_achievement.png",
        "link": "https://forest-kingdoms-rpg.com",
        "title": "Forest Kingdoms RPG Achievement"
    }
    
    var success = social_networks_api.share_content(network_name, content)
    if success:
        print("Content shared successfully on ", network_name)
    else:
        print("Failed to share content on ", network_name)

# Callback function for successful authentication
func _on_authentication_success(network_name: String, access_token: String, user_data: Dictionary):
    print("Authentication successful for ", network_name)
    print("Access token: ", access_token)
    print("User data: ", user_data)
    
    # Now we can share content
    demo_content_sharing(network_name)

# Callback function for failed authentication
func _on_authentication_failed(network_name: String, error_message: String):
    print("Authentication failed for ", network_name, ": ", error_message)