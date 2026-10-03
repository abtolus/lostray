class_name PlayerDataTres
extends DataTres

var user_data: Dictionary = {
	"last_main": "rainforest", "last_challenge": null, "authentication_token": "", "refresh_token": "", "id": "",
	"last_cloud_sync": ""
};
var personal_data: Dictionary = {
	"name": "", "sprite": "toyota_land_cruiser", "headlights_color": "ffffff", "underglow_light_color": "ffffff",
	"coins": 0
};
export var static_player_data: Dictionary = {
	"personal_data": personal_data, "user_data": user_data
};
