class_name GlobalDataTres
extends DataTres

var settings_data: Dictionary = {
	"music_volume": 100, "sound_effects_volume": 100,
	"times_of_day": {"canvas_modulate": "d6d6d6", "id": 0}, "camera_rotation_speed": {"value": 7.5, "id": 2},
	"difficulty": {"value": "Default", "id": 2}, "show_fps": false, "is_auto-acceleration_on": false
};
var challenge_data: Dictionary = {
	100: {"name": "The Lava Wall", "mode": 2,
	"description": "Avoid hitting walls since they are transformed into lava walls, but if you do so, your visibility becomes darker and darker so long as you are contacting the walls, and if your visibility becomes completely dark, you will be taken back to the starting point."},
	101: {"name": "The Broken Camera", "mode": 3,
	"description": "The camera following the vehicle now becomes malfunctioning, meaning that it waits a few seconds to proceed because of the partial circuit issues inside it; nevertheless, thanks to its high security, it can still do so but is slower than usual."},
	102: {"name": "The Reverse Universe", "mode": 4,
	"description": "The actions of turning left and right become in reverse, in which if you turn left, the vehicle turns right and vice versa, giving you the sense of difficulty by affecting the control of turning the vehicle; hence, bear in mind that you're in this converse world."},
	103: {"name": "The Reckless Drive", "mode": 5,
	"description": "Of the vehicle, the steering angle is linearly proportional to the total time of pressing the left or right button, meaning that the longer you press either of them, the steering angle becomes increased, and the grip of the vehicle already becomes looser."},
};
export var static_global_data: Dictionary = {"settings_data": settings_data, "challenge_data": challenge_data};
